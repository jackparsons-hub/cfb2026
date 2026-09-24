
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
## cfb_special_teams_model.R
##
## Pulls the last 4 completed seasons of CFBfastR data (team/game stats,
## ratings, and full play-by-play), engineers SPECIAL TEAMS features
## alongside the existing offense/defense features, trains on 3 seasons /
## validates on the 4th, and then applies the fitted pipeline to the
## in-progress current season two ways:
##   (a) BATCH  -- score every game on the current schedule at once
##   (b) WEEKLY -- walk-forward, one week at a time (reuses the same
##                 week-granularity framing as cfb_weekly_walkforward.R)
##
## NOTE ON API SURFACE: cfbfastR's function names/columns do shift between
## releases. Everything below is written defensively (checks colnames exist,
## wraps pulls in tryCatch) specifically so a mismatch fails loudly and early
## instead of silently producing an empty tabular_features frame like last
## time. Run `help(package = "cfbfastR")` and skim the vignette if any pull
## function below 404s or returns unexpected columns -- names below reflect
## the API as of early 2026 but were not executed in this environment.
## ============================================================================

library(cfbfastR)
library(dplyr)
library(purrr)
library(tidyr)
library(xgboost)
library(RPostgres)

# Requires: Sys.setenv(CFBD_API_KEY = "your_key_here") before sourcing this,
# or a .Renviron entry. cfbfastR::load_cfb_pbp() (bulk season loader) does
# NOT require a key for fully-completed seasons; cfbd_* live-endpoint calls
# for the in-progress current season DO require one.

# ----------------------------------------------------------------------------
# Config
# ----------------------------------------------------------------------------
CURRENT_SEASON <- 2026                     # season being predicted, in progress
HIST_YEARS     <- (CURRENT_SEASON - 4):(CURRENT_SEASON - 1)  # last 4 COMPLETED seasons
TRAIN_YEARS    <- HIST_YEARS[1:3]          # 3 years to train on
TEST_YEAR      <- HIST_YEARS[4]            # most recent completed season = holdout

message(sprintf("History: %s | Train: %s | Holdout test: %s | Predicting: %s",
                paste(HIST_YEARS, collapse = ","),
                paste(TRAIN_YEARS, collapse = ","),
                TEST_YEAR, CURRENT_SEASON))

# ----------------------------------------------------------------------------
# 1. Pull functions
# ----------------------------------------------------------------------------

# Bulk play-by-play for a completed season. Falls back to the live cfbd_plays()
# endpoint (needs API key, paginate by week) if load_cfb_pbp() doesn't have
# the season yet -- relevant for CURRENT_SEASON mid-year.
pull_pbp <- function(year) {
  pbp <- tryCatch(cfbfastR::load_cfb_pbp(year), error = function(e) NULL)
  if (is.null(pbp) || nrow(pbp) == 0) {
    message(sprintf("load_cfb_pbp(%d) empty/unavailable, falling back to cfbd_plays() by week", year))
    weeks <- 0:15
    pbp <- map_dfr(weeks, function(w) {
      tryCatch(cfbfastR::cfbd_plays(year = year, week = w), error = function(e) tibble())
    })
  }
  pbp
}

pull_games <- function(year) {
  cfbfastR::cfbd_game_info(year = year)
}

pull_ratings <- function(year) {
  elo  <- tryCatch(cfbfastR::cfbd_ratings_elo(year = year), error = function(e) tibble())
  fpi  <- tryCatch(cfbfastR::cfbd_ratings_fpi(year = year), error = function(e) tibble())
  sp   <- tryCatch(cfbfastR::cfbd_ratings_sp(year = year), error = function(e) tibble())
  list(elo = elo, fpi = fpi, sp = sp)
}

# ----------------------------------------------------------------------------
# 2. Special-teams feature engineering from play-by-play
#
# Special teams plays are identified off `play_type`. The exact label set has
# drifted across cfbfastR versions -- inspect `unique(pbp$play_type)` after
# your first real pull and adjust `st_play_types` if labels differ.
# ----------------------------------------------------------------------------
st_play_types <- c(
  "Punt", "Blocked Punt", "Blocked Punt Touchdown", "Punt Return Touchdown",
  "Field Goal Good", "Field Goal Missed", "Blocked Field Goal",
  "Kickoff", "Kickoff Return Touchdown", "Kickoff Return (Offense)",
  "Extra Point Good", "Extra Point Missed"
)

build_special_teams_features <- function(pbp) {
  stopifnot(all(c("play_type", "pos_team", "def_pos_team", "yards_gained") %in% colnames(pbp)))
  
  st <- pbp %>% filter(play_type %in% st_play_types)
  
  fg_stats <- st %>%
    filter(play_type %in% c("Field Goal Good", "Field Goal Missed")) %>%
    group_by(team = pos_team, game_id) %>%
    summarise(
      fg_att  = n(),
      fg_made = sum(play_type == "Field Goal Good"),
      .groups = "drop"
    ) %>%
    mutate(fg_pct = ifelse(fg_att > 0, fg_made / fg_att, NA_real_))
  
  punt_stats <- st %>%
    filter(play_type %in% c("Punt", "Blocked Punt", "Blocked Punt Touchdown", "Punt Return Touchdown")) %>%
    group_by(team = pos_team, game_id) %>%
    summarise(
      punts             = n(),
      punt_net_yards_avg = mean(yards_gained, na.rm = TRUE),
      punts_blocked      = sum(play_type %in% c("Blocked Punt", "Blocked Punt Touchdown")),
      .groups = "drop"
    )
  
  # Return yardage credited to the RECEIVING team (def_pos_team on a punt/kick)
  return_stats <- st %>%
    filter(play_type %in% c("Punt Return Touchdown", "Kickoff Return Touchdown", "Kickoff Return (Offense)")) %>%
    group_by(team = def_pos_team, game_id) %>%
    summarise(
      return_plays     = n(),
      return_yards_avg = mean(yards_gained, na.rm = TRUE),
      return_tds        = sum(grepl("Touchdown", play_type)),
      .groups = "drop"
    )
  
  blocked_against <- st %>%
    filter(play_type %in% c("Blocked Punt", "Blocked Punt Touchdown", "Blocked Field Goal")) %>%
    group_by(team = def_pos_team, game_id) %>%
    summarise(blocks_forced = n(), .groups = "drop")
  
  st_epa <- if ("EPA" %in% colnames(pbp)) {
    st %>% group_by(team = pos_team, game_id) %>%
      summarise(st_epa_per_play = mean(EPA, na.rm = TRUE), .groups = "drop")
  } else {
    message("No EPA column found on play-by-play -- st_epa_per_play will be NA. Check pull_pbp() output.")
    tibble(team = character(), game_id = character(), st_epa_per_play = numeric())
  }
  
  fg_stats %>%
    full_join(punt_stats,      by = c("team", "game_id")) %>%
    full_join(return_stats,    by = c("team", "game_id")) %>%
    full_join(blocked_against, by = c("team", "game_id")) %>%
    full_join(st_epa,          by = c("team", "game_id")) %>%
    mutate(across(c(fg_att, fg_made, punts, punts_blocked, return_plays,
                    return_tds, blocks_forced), ~ replace_na(.x, 0)))
}

# ----------------------------------------------------------------------------
# 3. Build one season's tabular feature frame: existing O/D features +
#    ratings diffs + the new special-teams diffs, joined pairwise (home/away)
# ----------------------------------------------------------------------------
build_season_tabular <- function(year) {
  games <- pull_games(year)
  pbp   <- pull_pbp(year)
  rat   <- pull_ratings(year)
  st    <- build_special_teams_features(pbp)
  
  # Season-to-date rolling special-teams form, computed BEFORE each game so
  # nothing leaks future information into that game's row -- mirrors how
  # home_roll_epa/away_roll_epa were already computed for O/D.
  st_rolling <- st %>%
    arrange(team, game_id) %>%
    group_by(team) %>%
    mutate(across(c(fg_pct, punt_net_yards_avg, return_yards_avg,
                    st_epa_per_play, punts_blocked, blocks_forced),
                  ~ lag(cummean(replace_na(.x, 0))),
                  .names = "roll_{.col}")) %>%
    ungroup()
  
  games %>%
    left_join(st_rolling %>% rename_with(~ paste0("home_", .x), -c(game_id)),
              by = c("game_id", "home_team" = "home_team")) %>%
    left_join(st_rolling %>% rename_with(~ paste0("away_", .x), -c(game_id)),
              by = c("game_id", "away_team" = "away_team")) %>%
    left_join(rat$elo %>% select(team, elo_home = elo), by = c("home_team" = "team")) %>%
    left_join(rat$elo %>% select(team, elo_away = elo), by = c("away_team" = "team")) %>%
    left_join(rat$fpi %>% select(team, fpi_home = fpi), by = c("home_team" = "team")) %>%
    left_join(rat$fpi %>% select(team, fpi_away = fpi), by = c("away_team" = "team")) %>%
    left_join(rat$sp  %>% select(team, sp_home = sp_overall), by = c("home_team" = "team")) %>%
    left_join(rat$sp  %>% select(team, sp_away = sp_overall), by = c("away_team" = "team")) %>%
    transmute(
      season = year, week, game_id,
      elo_diff     = elo_home - elo_away,
      fpi_diff     = fpi_home - fpi_away,
      sp_plus_diff = sp_home - sp_away,
      st_fg_pct_diff        = home_roll_fg_pct - away_roll_fg_pct,
      st_punt_net_diff      = home_roll_punt_net_yards_avg - away_roll_punt_net_yards_avg,
      st_return_yards_diff  = home_roll_return_yards_avg - away_roll_return_yards_avg,
      st_epa_diff           = home_roll_st_epa_per_play - away_roll_st_epa_per_play,
      st_blocks_forced_diff = home_roll_blocks_forced - away_roll_blocks_forced,
      label_win    = as.integer(home_points > away_points),
      label_spread = home_points - away_points
    )
}

message("Pulling and building historical seasons (this hits the CFBD API / bulk pbp repo per year)...")
historical <- map_dfr(HIST_YEARS, build_season_tabular)
saveRDS(historical, "tabular_features_with_special_teams.rds")

# ----------------------------------------------------------------------------
# 4. Train on 3 years / test on the 4th holdout year
# ----------------------------------------------------------------------------
feat_cols <- c("elo_diff", "fpi_diff", "sp_plus_diff",
               "st_fg_pct_diff", "st_punt_net_diff", "st_return_yards_diff",
               "st_epa_diff", "st_blocks_forced_diff")

train <- historical %>% filter(season %in% TRAIN_YEARS) %>% drop_na(all_of(c(feat_cols, "label_spread")))
test  <- historical %>% filter(season == TEST_YEAR)      %>% drop_na(all_of(feat_cols))

stopifnot(nrow(train) > 0, nrow(test) > 0)

dtrain <- xgb.DMatrix(as.matrix(train[feat_cols]), label = train$label_spread)
dtest  <- xgb.DMatrix(as.matrix(test[feat_cols]))

fit_st_model <- xgb.train(
  params = list(objective = "reg:squarederror", max_depth = 4, eta = 0.05, subsample = 0.8),
  data = dtrain, nrounds = 300, verbose = 0
)

pred_spread <- predict(fit_st_model, dtest)
pred_prob   <- 1 / (1 + exp(-pred_spread / 7))
actual_win  <- as.integer(test$label_spread > 0)

holdout_metrics <- tibble(
  metric = c("accuracy", "spread_mae", "spread_rmse"),
  value  = c(
    mean((pred_prob > 0.5) == (actual_win == 1)),
    mean(abs(pred_spread - test$label_spread)),
    sqrt(mean((pred_spread - test$label_spread)^2))
  )
)
message(sprintf("Holdout (%d) results with special teams features included:", TEST_YEAR))
print(holdout_metrics)

# Feature importance -- confirms whether special teams diffs are pulling
# their weight vs. just elo/fpi/sp+
print(xgb.importance(feature_names = feat_cols, model = fit_st_model))

# ----------------------------------------------------------------------------
# 5. Apply to the current season -- (a) BATCH, all games at once
# ----------------------------------------------------------------------------
message(sprintf("Building current-season (%d) tabular frame for batch scoring...", CURRENT_SEASON))
current_season_tabular <- build_season_tabular(CURRENT_SEASON)

batch_test <- current_season_tabular %>% drop_na(all_of(feat_cols))
batch_pred_spread <- predict(fit_st_model, xgb.DMatrix(as.matrix(batch_test[feat_cols])))
batch_pred_prob   <- 1 / (1 + exp(-batch_pred_spread / 7))

batch_predictions <- batch_test %>%
  transmute(season, week, game_id,
            pred_spread = batch_pred_spread,
            pred_win_prob = batch_pred_prob)
print(batch_predictions)

# ----------------------------------------------------------------------------
# 6. Apply to the current season -- (b) WEEKLY, walk-forward one week at a time
#
# Training frame per week = TRAIN_YEARS + TEST_YEAR (all completed history)
# + current season's weeks strictly before the target week. This is the same
# week-granularity framing as cfb_weekly_walkforward.R, just against the
# special-teams-augmented feature set built here.
# ----------------------------------------------------------------------------
full_history <- bind_rows(historical, current_season_tabular)

weeks_in_current <- current_season_tabular %>% pull(week) %>% unique() %>% sort()
MIN_TEST_WEEK <- 3
weekly_predictions <- map_dfr(weeks_in_current[weeks_in_current >= MIN_TEST_WEEK], function(w) {
  wk_train <- full_history %>%
    filter(season < CURRENT_SEASON | (season == CURRENT_SEASON & week < w)) %>%
    drop_na(all_of(c(feat_cols, "label_spread")))
  wk_test <- full_history %>%
    filter(season == CURRENT_SEASON, week == w) %>%
    drop_na(all_of(feat_cols))
  
  if (nrow(wk_train) == 0 || nrow(wk_test) == 0) {
    message(sprintf("week %d: skipped (empty train/test)", w))
    return(tibble())
  }
  
  wk_fit <- xgb.train(
    params = list(objective = "reg:squarederror", max_depth = 4, eta = 0.05, subsample = 0.8),
    data = xgb.DMatrix(as.matrix(wk_train[feat_cols]), label = wk_train$label_spread),
    nrounds = 300, verbose = 0
  )
  wk_pred_spread <- predict(wk_fit, xgb.DMatrix(as.matrix(wk_test[feat_cols])))
  wk_pred_prob   <- 1 / (1 + exp(-wk_pred_spread / 7))
  
  wk_test %>%
    transmute(season, week, game_id,
              pred_spread = wk_pred_spread,
              pred_win_prob = wk_pred_prob)
})

print(weekly_predictions)

saveRDS(list(holdout_metrics = holdout_metrics,
             batch_predictions = batch_predictions,
             weekly_predictions = weekly_predictions,
             model = fit_st_model),
        "cfb_special_teams_results.rds")
