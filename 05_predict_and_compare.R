con <- dbConnect(
  RPostgres::Postgres(),
  dbname = "",
  host = "localhost",
  port = 5432,
  user = "",
  password = ""
)

# ==============================================================================
# 05_predict_and_compare.R
# For the upcoming week's schedule: generate a pairwise prediction per game
# from the selected champion model, attach a CONFIDENCE LEVEL + interval driven
# by how sampled each team is (cumulative like-to-like plays, MIN_SAMPLE_PLAYS
# threshold from 03_feature_engineering.R), write to `predictions`, and pull
# the matching CFBfastR/ESPN benchmark fields (Vegas consensus spread, FPI
# implied spread, Elo win prob) side-by-side for comparison + a weekly report.
# ==============================================================================

library(DBI); library(RPostgres); library(dplyr); library(cfbfastR); library(glue)

dbExecute(con, "SET search_path TO cfb2026, public;")

CHAMPION_MODEL   <- Sys.getenv("CHAMPION_MODEL", "gru")  # set after 04_model_comparison.R picks a winner
TARGET_WEEK      <- as.integer(Sys.getenv("TARGET_WEEK", "1"))
SEASON           <- 2026
MIN_SAMPLE_PLAYS <- 320   # keep in sync with 03_feature_engineering.R

upcoming <- dbGetQuery(con, glue(
  "SELECT * FROM cfb2026.v_game_features WHERE season = {SEASON} AND week = {TARGET_WEEK};"
))

# ---- Attach each team's cumulative like-to-like sample size heading into --
# ---- this week (latest v_team_play_history row strictly before TARGET_WEEK) -
play_history <- dbGetQuery(con, glue(
  "SELECT team_id, week, cumulative_plays_through_week
   FROM cfb2026.v_team_play_history
   WHERE season = {SEASON} AND week < {TARGET_WEEK};"
))
latest_cume <- function(team_ids) {
  vapply(team_ids, function(tid) {
    rows <- play_history %>% filter(team_id == tid)
    if (nrow(rows) == 0) return(0L)
    rows %>% filter(week == max(week)) %>% pull(cumulative_plays_through_week) %>% .[1]
  }, integer(1))
}
upcoming <- upcoming %>%
  mutate(
    home_cumulative_plays = latest_cume(home_team_id),
    away_cumulative_plays = latest_cume(away_team_id),
    min_cumulative_plays = pmin(home_cumulative_plays, away_cumulative_plays)
  )

# ---- Confidence bucket, keyed off MIN_SAMPLE_PLAYS -------------------------
# low    < 160 plays  (~0-2 like-to-like games for the LESS-sampled team)
# medium 160-319      (~2-4 games)
# high   >= 320       (~4+ games) -- MIN_SAMPLE_PLAYS itself
confidence_bucket <- function(plays) {
  case_when(
    plays >= MIN_SAMPLE_PLAYS ~ "high",
    plays >= MIN_SAMPLE_PLAYS / 2 ~ "medium",
    TRUE ~ "low"
  )
}
upcoming <- upcoming %>% mutate(confidence_level = confidence_bucket(min_cumulative_plays))

# ---- Interval half-width: pull the CHAMPION_MODEL's own bucketed spread ----
# ---- RMSE from model_eval (logged by 04_model_comparison.R), matched to ----
# ---- each game's confidence bucket -- NOT an arbitrary widening, it's the --
# ---- model's actual historical error in that exact sample-size regime. ----
bucket_label_map <- c(low = "0-1 games", medium = "2-3 games", high = "4+ games (>=320 plays)")
bucket_rmse <- dbGetQuery(con, glue(
  "SELECT split, metric_value AS rmse
   FROM cfb2026.model_eval me
   JOIN cfb2026.model_runs mr ON mr.run_id = me.run_id
   WHERE mr.model_name = '{CHAMPION_MODEL}' AND me.metric_name = 'spread_rmse'
     AND me.split LIKE '%games%'
   ORDER BY me.run_id DESC;"
))
lookup_rmse <- function(conf_level) {
  target_split_fragment <- bucket_label_map[[conf_level]]
  hit <- bucket_rmse %>% filter(grepl(target_split_fragment, split, fixed = TRUE))
  if (nrow(hit) == 0) return(NA_real_)  # no logged bucket yet -- fall back to overall RMSE below
  hit$rmse[1]
}
fallback_rmse <- suppressWarnings(dbGetQuery(con, glue(
  "SELECT AVG(metric_value) AS rmse FROM cfb2026.model_eval me
   JOIN cfb2026.model_runs mr ON mr.run_id = me.run_id
   WHERE mr.model_name = '{CHAMPION_MODEL}' AND me.metric_name = 'spread_rmse';"
))$rmse[1])
if (is.na(fallback_rmse)) fallback_rmse <- 10.5  # coarse default if no eval history exists yet

upcoming <- upcoming %>%
  rowwise() %>%
  mutate(interval_half_width = {
    r <- lookup_rmse(confidence_level)
    if (is.na(r)) fallback_rmse else r
  }) %>%
  ungroup()

# Placeholder call-out to the trained champion model artifact (saved by 04_*.R
# via torch_save()/xgb.save()); loads it and scores `upcoming` here.
# model <- torch_load(glue("models/{CHAMPION_MODEL}_latest.pt"))
# preds <- predict_fn(model, upcoming)   # -> pred_spread, pred_home_win_prob
upcoming <- upcoming %>%
  mutate(
    predicted_spread = NA_real_,        # wire in preds$pred_spread here
    predicted_home_win_prob = NA_real_, # wire in preds$pred_home_win_prob here
    predicted_spread_low = predicted_spread - interval_half_width,
    predicted_spread_high = predicted_spread + interval_half_width
  )

run_id <- dbGetQuery(con, glue(
  "INSERT INTO cfb2026.model_runs (model_name, model_version, train_window_start, train_window_end)
   VALUES ('{CHAMPION_MODEL}', 'v1', 2015, {SEASON - 1}) RETURNING run_id;"
))$run_id

preds_df <- upcoming %>%
  transmute(
    run_id, game_id,
    predicted_home_points = NA_real_, predicted_away_points = NA_real_,  # wire in once preds available
    predicted_spread, predicted_home_win_prob,
    min_cumulative_plays, confidence_level,
    predicted_spread_low, predicted_spread_high
  )
dbWriteTable(con, "predictions", preds_df, append = TRUE)

# --- Comparison report: model vs. Vegas consensus vs. FPI-implied spread ---
comparison <- upcoming %>%
  transmute(
    game_id, matchup = paste(away_school, "@", home_school),
    min_cumulative_plays, confidence_level,
    predicted_spread, predicted_spread_low, predicted_spread_high,
    vegas_spread, fpi_implied_spread = home_fpi - away_fpi,
    elo_implied_spread = (home_elo - away_elo) / 25,   # ~25 elo pts per point of margin, rule of thumb
    sp_plus_implied_spread = home_sp_plus - away_sp_plus
  )

write.csv(comparison, glue("week{TARGET_WEEK}_comparison_{SEASON}.csv"), row.names = FALSE)
message(glue(
  "Wrote week{TARGET_WEEK}_comparison_{SEASON}.csv with {nrow(comparison)} games ",
  "({sum(comparison$confidence_level == 'low')} low-confidence, ",
  "{sum(comparison$confidence_level == 'high')} high-confidence)."
))

dbDisconnect(con)
