Sys.setenv(CFBD_API_KEY = "hyyrAkmzIZeY0usAzdOhFC1+SPWcImMVocJT2OjrVw56ULvOEedy0fXjplthXgJo")
Sys.setenv(psswrd = "StCroixRiver")


con <- dbConnect(
  RPostgres::Postgres(),
  dbname = "tsdb",
  host = "localhost",
  port = 5432,
  user = "jack",
  password = psswrd
)


## ============================================================================
## cfb_weekly_walkforward.R
##
## Fix for: Error in family$linkfun(mustart) : Argument mu must be a nonempty
##          numeric vector
##
## Root cause: the previous loop used SEASON-level walk-forward
## (train = all seasons < test_season). With only a couple of seasons of
## history, the earliest test_season in TEST_SEASONS had NO prior season to
## train on, so glm() got a 0-row data frame.
##
## Fix: walk forward at WEEK granularity instead. For a given (season, week)
## test split, training data = every prior season IN FULL, plus the current
## season's weeks strictly before the test week. This gives you a usable
## training set starting from week 1 of the earliest season with history,
## and keeps every split strictly forward-looking in time.
## ============================================================================

library(RPostgres)
library(dplyr)
library(purrr)
library(tidyr)
library(xgboost)

tabular <- readRDS("tabular_features.rds")

stopifnot(all(c("season", "week") %in% colnames(tabular)))

# ----------------------------------------------------------------------------
# Config
# ----------------------------------------------------------------------------
SEASONS <- sort(unique(tabular$season))

# Which season(s) to actually evaluate week-by-week. Default: just the most
# recent (current) season, since that's the one you're predicting live.
# Set to tail(SEASONS, 2) etc. if you want multiple seasons of week-level
# backtest instead of only the current one.
TEST_SEASONS <- tail(SEASONS, 1)

# Don't test weeks so early that even the full training history has almost
# no like-to-like signal yet -- matches the week-5-7 ramp discussed for
# CFB2026. Tune this down if you want to see how bad predictions are before
# the sample-size floor is hit.
MIN_TEST_WEEK <- 3

# ----------------------------------------------------------------------------
# Metrics
# ----------------------------------------------------------------------------
metrics <- list()
log_metric <- function(model_name, split, name, value) {
  metrics[[length(metrics) + 1]] <<- tibble(model_name, split, metric = name, value = value)
}

accuracy    <- function(pred_prob, actual_win) mean((pred_prob > 0.5) == (actual_win == 1))
log_loss    <- function(pred_prob, actual_win) {
  p <- pmin(pmax(pred_prob, 1e-6), 1 - 1e-6)
  -mean(actual_win * log(p) + (1 - actual_win) * log(1 - p))
}
brier       <- function(pred_prob, actual_win) mean((pred_prob - actual_win)^2)
spread_mae  <- function(pred_spread, actual_spread) mean(abs(pred_spread - actual_spread))
spread_rmse <- function(pred_spread, actual_spread) sqrt(mean((pred_spread - actual_spread)^2))

# ----------------------------------------------------------------------------
# Week-granularity train/test framing
# ----------------------------------------------------------------------------
train_frame_for <- function(test_season, test_week) {
  tabular %>%
    filter(season < test_season | (season == test_season & week < test_week))
}
test_frame_for <- function(test_season, test_week) {
  tabular %>% filter(season == test_season, week == test_week)
}

# ----------------------------------------------------------------------------
# Models (same two as before, now parameterized by week as well as season)
# ----------------------------------------------------------------------------
run_elo_logit <- function(test_season, test_week) {
  train <- train_frame_for(test_season, test_week) %>%
    drop_na(label_win, elo_diff, fpi_diff, sp_plus_diff)
  test <- test_frame_for(test_season, test_week)
  if (nrow(train) == 0 || nrow(test) == 0) return(NULL)
  
  fit <- glm(label_win ~ elo_diff + fpi_diff + sp_plus_diff, data = train, family = binomial())
  pred_prob <- predict(fit, newdata = test, type = "response")
  pred_spread <- fit$coefficients["elo_diff"] * test$elo_diff / 25  # crude points scaling
  list(pred_prob = pred_prob, pred_spread = pred_spread, actual = test)
}

run_xgboost <- function(test_season, test_week) {
  feat_cols <- c("elo_diff", "fpi_diff", "sp_plus_diff",
                 "home_roll_epa", "away_roll_epa", "home_roll_sr", "away_roll_sr")
  feat_cols <- intersect(feat_cols, colnames(tabular))
  
  train <- train_frame_for(test_season, test_week) %>%
    drop_na(all_of(c(feat_cols, "label_spread")))
  test <- test_frame_for(test_season, test_week) %>%
    drop_na(all_of(feat_cols))
  if (nrow(train) == 0 || nrow(test) == 0) return(NULL)
  
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

runners <- list(elo_logit = run_elo_logit, xgboost = run_xgboost)

# ----------------------------------------------------------------------------
# Walk-forward loop: season -> week -> model
# ----------------------------------------------------------------------------


#############################################################################################


# Safe logging list
metrics_list <- list()

for (test_season in TEST_SEASONS) {
  weeks_in_season <- tabular %>%
    filter(season == test_season) %>%
    pull(week) %>%
    unique() %>%
    sort()
  
  test_weeks <- weeks_in_season[weeks_in_season >= MIN_TEST_WEEK]
  
  for (test_week in test_weeks) {
    for (model_label in names(runners)) {
      res <- runners[[model_label]](test_season, test_week)
      
      if (is.null(res) || nrow(res$actual) == 0) {
        message(sprintf("[%s] season %d week %d: skipped (empty train/test after NA drop)",
                        model_label, test_season, test_week))
        next
      }
      
      actual_win <- as.integer(res$actual$label_spread > 0)
      split_label <- sprintf("season_%d_week_%02d", test_season, test_week)
      
      # Local accumulation frame
      current_metrics <- tibble(
        model_name = model_label,
        split = split_label,
        metric = c("accuracy", "log_loss", "brier", "spread_mae", "spread_rmse", "n_games"),
        value = c(
          accuracy(res$pred_prob, actual_win),
          log_loss(res$pred_prob, actual_win),
          brier(res$pred_prob, actual_win),
          spread_mae(res$pred_spread, res$actual$label_spread),
          spread_rmse(res$pred_spread, res$actual$label_spread),
          nrow(res$actual)
        )
      )
      
      metrics_list[[length(metrics_list) + 1]] <- current_metrics
      
      # Bucket metrics
      if ("home_cumulative_plays_to_date" %in% colnames(res$actual) && 
          "away_cumulative_plays_to_date" %in% colnames(res$actual)) {
        
        min_plays <- pmin(res$actual$home_cumulative_plays_to_date,
                          res$actual$away_cumulative_plays_to_date, na.rm = TRUE)
        
        bucket <- cut(min_plays, breaks = c(-Inf, 80, 160, 240, 320, Inf),
                      labels = c("0-1 games", "1-2 games", "2-3 games",
                                 "3-4 games", "4+ games (>=320 plays)"))
        
        for (b in levels(bucket)) {
          idx <- which(bucket == b)
          if (length(idx) >= 10) {
            bucket_split <- paste0(split_label, "_", b)
            
            bucket_metrics <- tibble(
              model_name = model_label,
              split = bucket_split,
              metric = c("accuracy", "spread_rmse", "n_games"),
              value = c(
                accuracy(res$pred_prob[idx], actual_win[idx]),
                spread_rmse(res$pred_spread[idx], res$actual$label_spread[idx]),
                length(idx)
              )
            )
            metrics_list[[length(metrics_list) + 1]] <- bucket_metrics
          }
        }
      }
    }
  }
}

metrics_df <- bind_rows(metrics_list)

# Safely print results
if (nrow(metrics_df) > 0) {
  metrics_df %>%
    filter(metric == "accuracy", grepl("^season_\\d+_week_\\d+$", split)) %>%
    arrange(model_name, split) %>%
    print(n = Inf)
} else {
  warning("No metrics were logged. Check if `tabular` contains valid non-NA rows for the specified TEST_SEASONS.")
}


#####################################################################################################################
# Convenience view: accuracy trend by week, per model, ignoring bucket splits
metrics_df %>%
  filter(metric == "accuracy", grepl("^season_\\d+_week_\\d+$", split)) %>%
  arrange(model_name, split) %>%
  print(n = Inf)

