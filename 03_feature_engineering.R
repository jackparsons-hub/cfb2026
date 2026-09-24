psswrd <- "StCroixRiver"

# ==============================================================================
# 03_feature_engineering.R (Updated)
# ==============================================================================

library(DBI)
library(RPostgres)
library(dplyr)
library(tidyr)
library(purrr)
library(zoo)

# Keep FALSE to retain early-season P4 vs P4 games in the base frame,
# allowing rolling stats to compute across all games while tracking sample counts.
LIKE_TO_LIKE_ONLY <- FALSE

con <- dbConnect(
  RPostgres::Postgres(),
  host = Sys.getenv("PGHOST", "localhost"),
  dbname = Sys.getenv("PGDATABASE", "tsdb"),
  user = Sys.getenv("PGUSER", "jack"),
  password = Sys.getenv("PGPASSWORD", psswrd )
)

stats <- dbGetQuery(con, "
  SELECT g.season, g.week, g.start_date, gt.like_to_like, gt.home_tier, gt.away_tier,
         s.team_id, s.opponent_id, s.is_home,
         s.points,
         s.offensive_plays, s.yards_per_play, s.epa_per_play, s.success_rate, s.explosiveness,
         s.offensive_plays_ex_garbage, s.yards_per_play_ex_garbage,
         s.epa_per_play_ex_garbage, s.success_rate_ex_garbage,
         s.turnovers, s.third_down_pct,
         r.elo_rating, r.fpi_rating, r.sp_plus_rating
  FROM cfb2026.game_team_stats s
  JOIN cfb2026.games g ON g.game_id = s.game_id
  JOIN cfb2026.v_games_tiered gt ON gt.game_id = g.game_id
  LEFT JOIN cfb2026.team_week_ratings r ON r.team_id = s.team_id AND r.season = g.season AND r.week = g.week
  ORDER BY s.team_id, g.season, g.week;")

like_to_like_counts <- dbGetQuery(con, "SELECT * FROM cfb2026.v_team_like_to_like_counts;")
dbDisconnect(con)
like_to_like_counts

if (LIKE_TO_LIKE_ONLY) {
  stats <- stats %>% filter(like_to_like)
}

ROLL_N <- 5
MIN_SAMPLE_PLAYS <- 320

team_features <- stats %>%
  group_by(team_id) %>%
  arrange(season, week, .by_group = TRUE) %>%
  mutate(
    roll_ypp    = lag(rollapplyr(yards_per_play, ROLL_N, mean, partial = TRUE, na.rm = TRUE)),
    roll_epa    = lag(rollapplyr(epa_per_play,   ROLL_N, mean, partial = TRUE, na.rm = TRUE)),
    roll_sr     = lag(rollapplyr(success_rate,   ROLL_N, mean, partial = TRUE, na.rm = TRUE)),
    roll_explosiveness = lag(rollapplyr(explosiveness, ROLL_N, mean, partial = TRUE, na.rm = TRUE)),
    roll_turnovers = lag(rollapplyr(turnovers,   ROLL_N, mean, partial = TRUE, na.rm = TRUE)),
    roll_ypp_ex_garbage = lag(rollapplyr(yards_per_play_ex_garbage, ROLL_N, mean, partial = TRUE, na.rm = TRUE)),
    roll_epa_ex_garbage  = lag(rollapplyr(epa_per_play_ex_garbage,  ROLL_N, mean, partial = TRUE, na.rm = TRUE)),
    roll_sr_ex_garbage   = lag(rollapplyr(success_rate_ex_garbage,  ROLL_N, mean, partial = TRUE, na.rm = TRUE)),
    rest_days   = as.numeric(difftime(start_date, lag(start_date), units = "days")),
    elo_pregame = lag(elo_rating),
    fpi_pregame = lag(fpi_rating),
    sp_plus_pregame = lag(sp_plus_rating),
    like_to_like_games_to_date = cumsum(coalesce(like_to_like, FALSE)) - as.integer(coalesce(like_to_like, FALSE)),
    cumulative_plays_to_date = lag(cumsum(coalesce(offensive_plays, 0)), default = 0),
    has_min_sample = cumulative_plays_to_date >= MIN_SAMPLE_PLAYS
  ) %>%
  ungroup()

saveRDS(team_features, "team_week3_features.rds")

# ---- (a) Tabular, game-grain feature set (home vs away joined) ------------
home_side <- team_features %>% filter(is_home) %>%
  rename_with(~ paste0("home_", .), -c(season, week, team_id, opponent_id))
away_side <- team_features %>% filter(!is_home) %>%
  rename_with(~ paste0("away_", .), -c(season, week, team_id, opponent_id))

tabular_features <- home_side %>%
  inner_join(away_side, by = c("season", "week",
                                "team_id" = "opponent_id", "opponent_id" = "team_id")) %>%
  mutate(
    elo_diff = home_elo_pregame - away_elo_pregame,
    fpi_diff = home_fpi_pregame - away_fpi_pregame,
    sp_plus_diff = home_sp_plus_pregame - away_sp_plus_pregame,
    label_spread = home_points - away_points,
    label_win = as.integer(label_spread > 0)
  )
saveRDS(tabular_features, "tabular_features_week3.rds")

# ---- (b) Per-team ordered sequences for RNN/Transformer models -------------
# Each team gets a matrix [n_games x n_features]; downstream script pads/masks
# to a fixed MAX_SEQ_LEN per season for batch training.
seq_cols <- c("roll_ypp","roll_epa","roll_sr","roll_explosiveness","roll_turnovers",
              "elo_pregame","fpi_pregame","sp_plus_pregame","rest_days","is_home")

team_sequences <- team_features %>%
  select(team_id, season, week, all_of(seq_cols)) %>%
  group_by(team_id, season) %>%
  group_split() %>%
  set_names(map_chr(., ~ paste0(.x$team_id[1], "_", .x$season[1])))

saveRDS(team_sequences, "team_sequences_week3.rds")

message(sprintf("Feature engineering complete: %d game rows, %d team-season sequences.",
                 nrow(tabular_features), length(team_sequences)))




# P4
# Conference,Team Count,Notable Recent Additions
# Big Ten,18,"Oregon, UCLA, USC, Washington"
# ACC,17,"Cal, SMU, Stanford"
# SEC,16,"Oklahoma, Texas"
# Big 12,16,"Arizona, Arizona State, Colorado, Utah, BYU, Cincinnati, Houston, UCF"
# total   -   67


# There are 68 teams competing across the non-power conferences. While this non-power 
# tier was historically called the "Group of Five" (G5), recent realignment and the 
# rebuilding of the Pac-12 expanded it into what is now widely referred to as the 
# Group of Six (G6):  
#    American Athletic Conference (AAC): 14 teams  
#    Sun Belt Conference: 14 teams
#    Mid-American Conference (MAC): 13 teams  
#    Conference USA (CUSA): 10 teams
#    Mountain West Conference (MWC): 9 teams  
#    Pac-12 Conference: 8 football members (restructured league after adding 
#      Boise State, Colorado State, Fresno State, San Diego State, Utah State, 
#      and Texas State)  (includes Oregon State and Washington State)

