
# install_torch()

con <- dbConnect(
  RPostgres::Postgres(),
  dbname = "",
  host = "localhost",
  port = 5432,
  user = "",
  password = ""
)



# ==============================================================================
# 04_model_comparison.R
# Trains and walk-forward-validates four model families on the same targets
# (predicted_spread, predicted_home_win_prob) and logs results to model_eval.
#
#   1. elo_logit   -- logistic regression on elo/fpi/sp+ diffs (sanity baseline)
#   2. xgboost     -- gradient-boosted trees on tabular_features.rds
#   3. gru         -- recurrent net on team_sequences.rds (torch for R)
#   4. lstm        -- recurrent net, same sequences, LSTM cell instead of GRU
#   5. transformer -- small encoder-only transformer, same sequences (torch for R)
#
# Validation: walk-forward by season (train on seasons < test_season, i.e. no
# future leakage), NOT a random k-fold -- random folds would leak future-season
# team strength into training and inflate accuracy.
# ==============================================================================

library(DBI); 
library(RPostgres)
library(dplyr) 
library(purrr)
library(tidyr)
library(xgboost) 
library(torch)

tabular <- readRDS("tabular_features_week3.rds")
sequences <- readRDS("team_sequences_week3.rds")

SEASONS <- sort(unique(tabular$season))
TEST_SEASONS <- tail(SEASONS, 3)  # walk-forward: evaluate on last 3 seasons

metrics <- list()

log_metric <- function(model_name, split, name, value) {
  metrics[[length(metrics) + 1]] <<- tibble(model_name, split, metric = name, value = value)
}

accuracy <- function(pred_prob, actual_win) mean((pred_prob > 0.5) == (actual_win == 1))
log_loss <- function(pred_prob, actual_win) {
  p <- pmin(pmax(pred_prob, 1e-6), 1 - 1e-6)
  -mean(actual_win * log(p) + (1 - actual_win) * log(1 - p))
}
brier <- function(pred_prob, actual_win) mean((pred_prob - actual_win)^2)
spread_mae <- function(pred_spread, actual_spread) mean(abs(pred_spread - actual_spread))
spread_rmse <- function(pred_spread, actual_spread) sqrt(mean((pred_spread - actual_spread)^2))

# ------------------------------------------------------------------------
# 1. Elo/FPI/SP+ logistic baseline
# ------------------------------------------------------------------------
run_elo_logit <- function(test_season) {
  train <- tabular %>% filter(season < test_season)
  test  <- tabular %>% filter(season == test_season)
  fit <- glm(label_win ~ elo_diff + fpi_diff + sp_plus_diff, data = train, family = binomial())
  pred_prob <- predict(fit, newdata = test, type = "response")
  pred_spread <- fit$coefficients["elo_diff"] * test$elo_diff / 25   # crude points scaling
  list(pred_prob = pred_prob, pred_spread = pred_spread, actual = test)
}

# ------------------------------------------------------------------------
# 2. XGBoost tabular
# ------------------------------------------------------------------------
run_xgboost <- function(test_season) {
  train <- tabular %>% filter(season < test_season) %>% drop_na(elo_diff, fpi_diff, sp_plus_diff, label_spread)
  test  <- tabular %>% filter(season == test_season) %>% drop_na(elo_diff, fpi_diff, sp_plus_diff)
  feat_cols <- c("elo_diff", "fpi_diff", "sp_plus_diff",
                 "home_roll_epa", "away_roll_epa", "home_roll_sr", "away_roll_sr")
  feat_cols <- intersect(feat_cols, colnames(train))

  dtrain <- xgb.DMatrix(as.matrix(train[feat_cols]), label = train$label_spread)
  dtest  <- xgb.DMatrix(as.matrix(test[feat_cols]))

  fit <- xgb.train(
    params = list(objective = "reg:squarederror", max_depth = 4, eta = 0.05, subsample = 0.8),
    data = dtrain, nrounds = 300, verbose = 0
  )
  pred_spread <- predict(fit, dtest)
  pred_prob <- 1 / (1 + exp(-pred_spread / 7))  # logistic squash of predicted margin -> win prob
  list(pred_prob = pred_prob, pred_spread = pred_spread, actual = test)
}

# ------------------------------------------------------------------------
# 3. GRU (torch for R) on padded team sequences, joined pairwise at predict time
# ------------------------------------------------------------------------
build_gru <- function(n_features, hidden = 32) {
  nn_module(
    "GameGRU",
    initialize = function() {
      self$gru <- nn_gru(input_size = n_features, hidden_size = hidden, batch_first = TRUE)
      self$head <- nn_linear(hidden * 2, 1)  # concat(home_hidden, away_hidden) -> spread
    },
    forward = function(home_x, away_x) {
      h_home <- self$gru(home_x)[[2]][1, , ]
      h_away <- self$gru(away_x)[[2]][1, , ]
      self$head(torch_cat(list(h_home, h_away), dim = 2))$squeeze(2)
    }
  )
}

# ------------------------------------------------------------------------
# 3b. LSTM (torch for R) -- same sequence inputs, LSTM cell instead of GRU.
# Fully native to `torch` for R (nn_lstm), no bridge or hand-rolled block
# needed. Worth the bake-off against GRU: LSTM's separate cell state can
# help on a team's longer within-season trajectory, at the cost of ~2x the
# gate parameters GRU uses -- more to overfit on a ~13-16-step sequence.
# ------------------------------------------------------------------------
build_lstm <- function(n_features, hidden = 32) {
  nn_module(
    "GameLSTM",
    initialize = function() {
      self$lstm <- nn_lstm(input_size = n_features, hidden_size = hidden, batch_first = TRUE)
      self$head <- nn_linear(hidden * 2, 1)  # concat(home_hidden, away_hidden) -> spread
    },
    forward = function(home_x, away_x) {
      h_home <- self$lstm(home_x)[[2]][[1]][1, , ]  # (output, (h_n, c_n)) -> h_n
      h_away <- self$lstm(away_x)[[2]][[1]][1, , ]
      self$head(torch_cat(list(h_home, h_away), dim = 2))$squeeze(2)
    }
  )
}

# ------------------------------------------------------------------------
# 4. Small Transformer encoder, same sequence inputs
# ------------------------------------------------------------------------
build_transformer <- function(n_features, d_model = 32, n_heads = 4, n_layers = 2) {
  nn_module(
    "GameTransformer",
    initialize = function() {
      self$proj <- nn_linear(n_features, d_model)
      encoder_layer <- nn_transformer_encoder_layer(d_model = d_model, nhead = n_heads,
                                                      dim_feedforward = d_model * 2, batch_first = TRUE)
      self$encoder <- nn_transformer_encoder(encoder_layer, num_layers = n_layers)
      self$head <- nn_linear(d_model * 2, 1)
    },
    forward = function(home_x, away_x) {
      h <- self$encoder(self$proj(home_x))[, -1, ]
      a <- self$encoder(self$proj(away_x))[, -1, ]
      self$head(torch_cat(list(h, a), dim = 2))$squeeze(2)
    }
  )
}

# NOTE: run_gru()/run_transformer() training loops (padding sequences to a
# fixed MAX_SEQ_LEN, batching, Adam optimizer, early stopping on validation
# spread RMSE) follow the same walk-forward split as run_xgboost() above --
# omitted here for length; scaffolding is in place via build_gru()/build_transformer().

# ------------------------------------------------------------------------
# Walk-forward evaluation loop (baselines shown; wire in GRU/Transformer once
# the training loops above are filled in)
# ------------------------------------------------------------------------
for (test_season in TEST_SEASONS) {
  for (runner in list(elo_logit = run_elo_logit, xgboost = run_xgboost)) {
    res <- runner(test_season)
    actual_win <- as.integer(res$actual$label_spread > 0)
    model_label <- names(which(sapply(list(elo_logit=run_elo_logit,xgboost=run_xgboost), identical, runner)))
    log_metric(model_label, paste0("test_", test_season), "accuracy", accuracy(res$pred_prob, actual_win))

    # ------------------------------------------------------------------
    # Sample-size check: does accuracy actually step up once BOTH teams
    # have cleared MIN_SAMPLE_PLAYS (320 like-to-like plays, ~4 games)?
    # Bucketed on the SMALLER of the two teams' cumulative play counts --
    # a matchup is only as "sampled" as its least-sampled participant.
    # ------------------------------------------------------------------
    min_plays <- pmin(res$actual$home_cumulative_plays_to_date,
                       res$actual$away_cumulative_plays_to_date)
    bucket <- cut(min_plays, breaks = c(-Inf, 80, 160, 240, 320, Inf),
                  labels = c("0-1 games","1-2 games","2-3 games","3-4 games","4+ games (>=320 plays)"))
    for (b in levels(bucket)) {
      idx <- which(bucket == b)
      if (length(idx) >= 10) {  # skip buckets too small to be meaningful
        log_metric(model_label, paste0("test_", test_season, "_", b), "accuracy",
                   accuracy(res$pred_prob[idx], actual_win[idx]))
        log_metric(model_label, paste0("test_", test_season, "_", b), "spread_rmse",
                   spread_rmse(res$pred_spread[idx], res$actual$label_spread[idx]))
        log_metric(model_label, paste0("test_", test_season, "_", b), "n_games", length(idx))
      }
    }
  }
}

# Print the sample-size bucket breakdown specifically, since that's the thing
# to actually look at: expect spread_rmse to drop and accuracy to rise once
# the "4+ games (>=320 plays)" bucket is reached, relative to the 0-1/1-2
# buckets where per-play rate stats are still a small, noisy sample.
bind_rows(metrics) %>%
  filter(grepl("games", split)) %>%
  pivot_wider(names_from = metric, values_from = value) %>%
  arrange(model_name, split) %>%
  print(n = 100)

# ------------------------------------------------------------------------
# Model selection criteria (write-up, not code):
#   - Primary metric: spread RMSE against actual margin (what a bettor/analyst
#     cares about) and win-probability log loss (calibration).
#   - Secondary: accuracy vs. the *closing Vegas line's* implied pick (beating
#     a coin flip is trivial; beating the market's ATS pick is the real bar).
#   - Guard rail: walk-forward only, never k-fold -- avoids leaking a team's
#     later-season strength backward into earlier-week predictions.
#   - Final model choice = lowest spread RMSE on TEST_SEASONS with log loss
#     no worse than the elo_logit baseline (protects against a model that's
#     good on points but poorly calibrated on win probability).
#   - Sample-size validation: accuracy/spread RMSE are also reported bucketed
#     by min(home, away) cumulative like-to-like plays played (0-1/1-2/2-3/
#     3-4/4+ games, i.e. the 320-play = 4-game threshold). If the model is
#     actually using the atomic play-level rate stats correctly, expect a
#     visible step-up in accuracy and drop in spread RMSE once both teams
#     clear ~320 plays -- before that, roll_ypp/roll_epa/roll_sr are small-
#     sample estimates and predictions should be treated with more caution.
#     If no step-up shows up at that bucket, that's a signal to revisit
#     ROLL_N or the rate-stat calculation, not to assume the threshold is wrong.
# ------------------------------------------------------------------------

# LSTM vs. GRU: both are trained with the same walk-forward split and the
# same build_gru()/build_lstm() scaffolding above (training loop still to be
# filled in -- padding, batching, Adam, early stopping on val spread RMSE).
# Pick whichever wins on the same criteria as everything else in this file:
# lowest spread RMSE on TEST_SEASONS with log loss no worse than elo_logit.
# Given the modest sequence lengths here (~13-16 steps/season), expect the
# gap between them to be small either way -- this is a real bake-off, not a
# foregone conclusion in GRU's favor.

bind_rows(metrics) %>% print(n = 50)

dbDisconnect(con)
