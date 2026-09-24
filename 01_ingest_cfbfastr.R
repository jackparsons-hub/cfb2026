con <- dbConnect(
  RPostgres::Postgres(),
  dbname = "",
  host = "localhost",
  port = 5432,
  user = "",
  password = ""
)






# ==============================================================================
# 01_ingest_cfbfastr.R
# Pulls schedule, team box scores, advanced metrics, ratings (Elo/SP+), and
# betting lines via {cfbfastR} and upserts into the `cfb` Postgres schema.
#
# Requires: Sys.setenv(CFBD_API_KEY = "...")  (free key: collegefootballdata.com/key)
# Requires: Postgres connection env vars (PGHOST/PGPORT/PGDATABASE/PGUSER/PGPASSWORD)
#
# Note on FPI: cfbd's FPI endpoint mirrors ESPN's FPI (same source ESPN publishes
# publicly); there is no separate "ESPN scrape" needed for FPI itself. Vegas/ESPN
# BET lines both come back through cfbd_betting_lines() with a `provider` column.
# ==============================================================================

library(cfbfastR)
library(cfbplotR)
library(DBI)
library(RPostgres)
library(dplyr)
library(purrr)
library(glue)

SEASON <- 2026


dbExecute(con, "SET search_path TO cfb2026, public;")

# upsert <- function(df, table, keys) {
#   if (nrow(df) == 0) return(invisible(NULL))
   # cfbfastR tags its return objects with a custom "cfbfastR_data" class that
   # survives dplyr verbs like transmute()/mutate(). RPostgres's dbWriteTable
   # does S4 dispatch on that class and finds no method for it (only plain
   # data.frame) -- strip back to a bare data.frame before writing.


upsert <- function(df, table, keys) {
  if (nrow(df) == 0) return(invisible(NULL))
  
  # Ensure keys is a vector if passed as a comma-separated string
  if (length(keys) == 1 && grepl(",", keys)) {
    keys <- trimws(unlist(strsplit(keys, ",")))
  }
  
  df <- as.data.frame(df)
  
  # Guarantee uniqueness on specified keys before staging to PostgreSQL
  df <- df[!duplicated(df[keys]), ]
  
  col_types <- dbGetQuery(con, glue(
    "SELECT a.attname AS column_name, format_type(a.atttypid, a.atttypmod) AS data_type
     FROM pg_attribute a
     WHERE a.attrelid = '{table}'::regclass AND a.attnum > 0 AND NOT a.attisdropped
       AND a.attname IN ({paste(sprintf(\"'%s'\", colnames(df)), collapse = ', ')});"
  ))
  
  for (i in seq_len(nrow(col_types))) {
    cn <- col_types$column_name[i]; dt <- col_types$data_type[i]
    v <- df[[cn]]
    if (!is.character(v)) next
    if (grepl("^(integer|bigint|smallint|numeric|double precision|real)", dt)) {
      df[[cn]] <- suppressWarnings(as.numeric(v))
    } else if (grepl("^(timestamp|date)", dt)) {
      df[[cn]] <- suppressWarnings(as.POSIXct(v, format = "%Y-%m-%dT%H:%M:%OSZ", tz = "UTC"))
    } else if (dt == "boolean") {
      df[[cn]] <- as.logical(v)
    }
  }
  
  dbWriteTable(con, DBI::SQL(paste0("tmp_", table)), df, temporary = TRUE, overwrite = TRUE)
  
  cols <- colnames(df)
  set_clause <- paste(sprintf("%s = EXCLUDED.%s", cols, cols), collapse = ", ")
  key_clause <- paste(keys, collapse = ", ")
  
  sql <- glue(
    "INSERT INTO {table} ({paste(cols, collapse=', ')})
     SELECT {paste(cols, collapse=', ')} FROM tmp_{table}
     ON CONFLICT ({key_clause}) DO UPDATE SET {set_clause};"
  )
  
  dbExecute(con, sql)
  dbExecute(con, glue("DROP TABLE tmp_{table};"))
}
###################################################################################


# cfbfastR's column names have shifted across package versions/functions
# (offense_id vs offense_team_id vs pos_team_id; home_id vs home_team_id;
# EPA vs ppa; separate rush/pass flags vs a single rush_pass column). These
# resolve whichever variant is actually in YOUR installed version instead of
# hardcoding one -- if a section still errors, run `dplyr::glimpse(<raw df>)`
# once, share the real column names, and the mapping gets hard-fixed instead
# of re-guessed.
get_col <- function(df, candidates, default = NA) {
  hit <- intersect(candidates, colnames(df))
  if (length(hit) == 0) return(rep(default, nrow(df)))
  df[[hit[1]]]
}
has_col <- function(df, name) name %in% colnames(df)

upsert <- function(df, table, keys) {
  if (nrow(df) == 0) return(invisible(NULL))
  
  # Ensure keys is a vector if passed as a comma-separated string
  if (length(keys) == 1 && grepl(",", keys)) {
    keys <- trimws(unlist(strsplit(keys, ",")))
  }
  
  df <- as.data.frame(df)
  
  # Guarantee uniqueness on specified keys before staging to PostgreSQL
  df <- df[!duplicated(df[keys]), ]
  
  col_types <- dbGetQuery(con, glue(
    "SELECT a.attname AS column_name, format_type(a.atttypid, a.atttypmod) AS data_type
     FROM pg_attribute a
     WHERE a.attrelid = '{table}'::regclass AND a.attnum > 0 AND NOT a.attisdropped
       AND a.attname IN ({paste(sprintf(\"'%s'\", colnames(df)), collapse = ', ')});"
  ))
  
  for (i in seq_len(nrow(col_types))) {
    cn <- col_types$column_name[i]; dt <- col_types$data_type[i]
    v <- df[[cn]]
    if (!is.character(v)) next
    if (grepl("^(integer|bigint|smallint|numeric|double precision|real)", dt)) {
      df[[cn]] <- suppressWarnings(as.numeric(v))
    } else if (grepl("^(timestamp|date)", dt)) {
      df[[cn]] <- suppressWarnings(as.POSIXct(v, format = "%Y-%m-%dT%H:%M:%OSZ", tz = "UTC"))
    } else if (dt == "boolean") {
      df[[cn]] <- as.logical(v)
    }
  }
  
  dbWriteTable(con, DBI::SQL(paste0("tmp_", table)), df, temporary = TRUE, overwrite = TRUE)
  
  cols <- colnames(df)
  set_clause <- paste(sprintf("%s = EXCLUDED.%s", cols, cols), collapse = ", ")
  key_clause <- paste(keys, collapse = ", ")
  
  sql <- glue(
    "INSERT INTO {table} ({paste(cols, collapse=', ')})
     SELECT {paste(cols, collapse=', ')} FROM tmp_{table}
     ON CONFLICT ({key_clause}) DO UPDATE SET {set_clause};"
  )
  
  dbExecute(con, sql)
  dbExecute(con, glue("DROP TABLE tmp_{table};"))
}


# ---- 1. Teams -----------------------------------------------------------
teams_raw <- cfbd_team_info(year = SEASON)
teams <- teams_raw %>%
  transmute(
    team_id = team_id, school = school, conference = conference,
    division = classification, classification = classification,
    color = color, alt_color = alt_color, logo_url = logo, logo_url_alt = logo_2
  )
upsert(teams, "teams", "team_id")

# FBS independents don't map to a conference-based tier; classify by hand.
# Notre Dame plays a P4-caliber schedule -- treat as P4 for like-to-like
# purposes. UConn/UMass/etc. schedule like Group of Five -- treat as G5.
# Adjust this list if independent membership changes.
independent_tier_overrides <- tribble(
  ~school,        ~tier_override,
  "Notre Dame",   "P4",
  "UConn",        "G5",
  "UMass",        "G5"
)
if (nrow(independent_tier_overrides) > 0) {
  overrides <- teams %>%
    inner_join(independent_tier_overrides, by = "school") %>%
    select(team_id, tier_override) %>%
    as.data.frame()  # strip cfbfastR_data class -- same dbWriteTable dispatch issue as upsert()
  dbExecute(con, "CREATE TEMP TABLE tmp_tier_override (team_id INT, tier_override TEXT);")
  dbWriteTable(con, "tmp_tier_override", overrides, append = TRUE)
  dbExecute(con, "UPDATE teams SET tier_override = tmp_tier_override.tier_override
                  FROM tmp_tier_override WHERE teams.team_id = tmp_tier_override.team_id;")
  dbExecute(con, "DROP TABLE tmp_tier_override;")
}

# ---- 2. Schedule / games -------------------------------------------------
games_raw <- cfbd_game_info(year = SEASON, season_type = "both")
# home_id/away_id vs home_team_id/away_team_id also isn't fully certain across
# versions -- resolved the same defensive way as the pbp columns above.
.home_id <- get_col(games_raw, c("home_id", "home_team_id"))
.away_id <- get_col(games_raw, c("away_id", "away_team_id"))
# start_date comes back as a character ISO-8601 string (e.g.
# "2026-08-29T19:00:00.000Z"), not a real datetime. dbWriteTable() infers the
# temp table's column type from the R vector, so a character start_date makes
# a TEXT temp column -- which then fails to insert into games.start_date
# (TIMESTAMPTZ) because Postgres won't implicitly cast a column (as opposed
# to a literal) across that boundary. Parse it to POSIXct here, before it
# ever reaches dbWriteTable.
.start_date <- get_col(games_raw, c("start_date"))
if (is.character(.start_date)) {
  .start_date <- as.POSIXct(.start_date, format = "%Y-%m-%dT%H:%M:%OSZ", tz = "UTC")
}
games <- games_raw %>%
  mutate(.home_id = .home_id, .away_id = .away_id, .start_date = .start_date) %>%
  transmute(
    game_id, season = as.integer(season), week = as.integer(week),
    season_type, start_date = .start_date, neutral_site, conference_game,
    venue_id, home_team_id = .home_id, away_team_id = .away_id,
    home_points, away_points, completed
  )

# cfbd_team_info(year=SEASON) only returns FBS teams, but season_type="both"
# schedules genuinely include non-conference games against FCS opponents --
# and `games` has a foreign-key reference to `teams`. Backfill a minimal stub
# row (school name if we have it, everything else NULL) for any team_id that
# shows up as a home/away team but isn't in the FBS team list. This is the
# CORRECT outcome for like-to-like logic, not just a workaround: a stub row
# has no conference_tier_map match and no tier_override, so v_team_tier
# resolves it to tier = NULL -- exactly what should happen to an FCS cupcake
# opponent (never counted as like-to-like, per v_games_tiered).
.home_name <- get_col(games_raw, c("home_team", "home"))
.away_name <- get_col(games_raw, c("away_team", "away"))
referenced_teams <- bind_rows(
  data.frame(team_id = .home_id, school = .home_name),
  data.frame(team_id = .away_id, school = .away_name)
) %>%
  filter(!is.na(team_id)) %>%
  distinct(team_id, .keep_all = TRUE)

missing_teams <- referenced_teams %>% filter(!team_id %in% teams$team_id)
if (nrow(missing_teams) > 0) {
  stub <- missing_teams %>%
    transmute(
      team_id, school = coalesce(school, paste0("Unknown Team ", team_id)),
      conference = NA_character_, division = NA_character_,
      classification = NA_character_, color = NA_character_, alt_color = NA_character_,
      logo_url = NA_character_, logo_url_alt = NA_character_
    )
  upsert(stub, "teams", "team_id")
  message(sprintf(
    "Backfilled %d team stub(s) not covered by cfbd_team_info() (likely FCS opponents): %s",
    nrow(missing_teams), paste(stub$school, collapse = ", ")
  ))
}

upsert(games, "games", "game_id")

# ---- 3. ATOMIC GRAIN: play-by-play, then aggregate up ---------------------
# Everything downstream (yards-per-play, EPA/play, success rate) is computed
# from this table's rows, never taken pre-aggregated from a box score. This
# is what makes a 60-play team and a 100-play team comparable: every rate
# stat below is (sum over scrimmage plays) / (count of scrimmage plays),
# both computed here, not a box-score total divided by a play count nobody
# re-derives.

Sys.setenv(CFBD_API_KEY = "")


pbp_raw <- cfbd_pbp_data(year = SEASON, season_type = "both", epa_wpa = TRUE)

# cfbfastR's pbp column names have shifted across package versions/functions
# (offense_id vs offense_team_id vs pos_team_id; EPA vs ppa; separate rush/pass
# flags vs a single rush_pass column; garbage_time sometimes pre-computed by
# the API, sometimes not present at all). Resolved with get_col()/has_col()
# (defined above) rather than hardcoding one -- if it still errors, run
# `dplyr::glimpse(pbp_raw)` once and share the real column names.

# Non-scrimmage play types to exclude from the offensive-plays denominator --
# kickoffs, punts, FG/PAT, penalties with no play, timeouts, period markers.
NON_SCRIMMAGE_TYPES <- c(
  "Kickoff", "Kickoff Return (Offense)", "Punt", "Punt Return",
  "Field Goal Good", "Field Goal Missed", "Blocked Field Goal",
  "Extra Point Good", "Extra Point Missed", "Timeout",
  "End Period", "End of Half", "End of Game", "Penalty",
  "Uncategorized", "Placeholder"
)

.offense_id <- get_col(pbp_raw, c("offense_id", "offense_team_id", "pos_team_id"))
.defense_id <- get_col(pbp_raw, c("defense_id", "defense_team_id", "def_pos_team_id"))
# Same text-vs-numeric-column mismatch as start_date/play_id above -- team ID
# columns from cfbd_pbp_data() can come back as character too. text -> integer
# isn't an assignment-safe cast in Postgres either, so convert here.
if (is.character(.offense_id)) .offense_id <- as.integer(.offense_id)
if (is.character(.defense_id)) .defense_id <- as.integer(.defense_id)

# DIAGNOSED 2026-09: none of offense_id/offense_team_id/pos_team_id exist (or
# they exist but are entirely NA) in the pbp_raw shape this version of
# cfbfastR/CFBD is returning -- same "name string, not an ID column" shape we
# already had to handle for cfbd_game_team_stats() below. If the ID
# candidates didn't pan out, fall back to resolving team_id by name against
# `teams`, the same pattern used for the box-score join.
if (all(is.na(.offense_id)) || all(is.na(.defense_id))) {
  message(
    "offense/defense ID columns (offense_id/offense_team_id/pos_team_id) not ",
    "found or entirely NA in pbp_raw -- falling back to name-based team_id ",
    "lookup. Run dplyr::glimpse(pbp_raw) and add the real ID column name to ",
    "the get_col() candidates above if this message keeps appearing."
  )
  team_lookup_pbp <- dbGetQuery(con, "SELECT team_id, school FROM teams;")
  .offense_name <- get_col(pbp_raw, c("offense", "offense_play", "pos_team", "offense_team"))
  .defense_name <- get_col(pbp_raw, c("defense", "defense_play", "def_pos_team", "defense_team"))
  .offense_id <- team_lookup_pbp$team_id[match(.offense_name, team_lookup_pbp$school)]
  .defense_id <- team_lookup_pbp$team_id[match(.defense_name, team_lookup_pbp$school)]

  n_unmatched_off <- sum(is.na(.offense_id) & !is.na(.offense_name))
  n_unmatched_def <- sum(is.na(.defense_id) & !is.na(.defense_name))
  if (n_unmatched_off + n_unmatched_def > 0) {
    message(sprintf(
      "%d offense / %d defense play(s) had a name that didn't match `teams.school` -- likely spelling variants; those rows will have NA team_id and won't count toward is_scrimmage_play.",
      n_unmatched_off, n_unmatched_def
    ))
  }
}
.epa        <- get_col(pbp_raw, c("EPA", "epa", "ppa"))
.play_id    <- get_col(pbp_raw, c("id_play", "play_id"))
# CFBD play IDs are long enough that the API returns them as character
# strings (to avoid precision loss in JSON), same reason game_id sometimes
# does. dbWriteTable() would infer a TEXT temp column from a character
# vector, and text -> bigint is NOT an assignment-safe cast in Postgres (same
# failure mode as start_date earlier) -- so convert to numeric here, before
# it reaches dbWriteTable. double -> bigint IS an assignment-safe cast, so
# this resolves cleanly on insert. (Safe up to 2^53 -- these IDs are ~12-15
# digits, well under that.)
if (is.character(.play_id)) .play_id <- as.numeric(.play_id)
# Same precision-safe-string treatment for game_id here, since this is a
# DIFFERENT API pull (cfbd_pbp_data) than the one that already worked fine
# for the `games` table -- it can independently come back as character.
.pbp_game_id <- get_col(pbp_raw, c("game_id"))
if (is.character(.pbp_game_id)) .pbp_game_id <- as.numeric(.pbp_game_id)
.clock_min  <- get_col(pbp_raw, c("clock.minutes", "clock_minutes"), default = 0)
.clock_sec  <- get_col(pbp_raw, c("clock.seconds", "clock_seconds"), default = 0)
.rush_pass  <- if (has_col(pbp_raw, "rush_pass")) {
  pbp_raw$rush_pass
} else if (has_col(pbp_raw, "rush") && has_col(pbp_raw, "pass")) {
  case_when(pbp_raw$rush == 1 ~ "rush", pbp_raw$pass == 1 ~ "pass", TRUE ~ "other")
} else {
  rep("other", nrow(pbp_raw))
}
# Prefer the API's own garbage-time flag if this version provides one;
# otherwise fall back to a working definition (4th-quarter blowout margin
# that narrows as the clock runs out).
.garbage_time_api <- get_col(pbp_raw, c("garbage_time"))

plays <- pbp_raw %>%
  mutate(.offense_id = .offense_id, .defense_id = .defense_id, .epa = .epa,
         .play_id = .play_id, .pbp_game_id = .pbp_game_id,
         .clock_min = .clock_min, .clock_sec = .clock_sec,
         .rush_pass = .rush_pass, .garbage_time_api = .garbage_time_api) %>%
  transmute(
    play_id = .play_id, game_id = .pbp_game_id,
    offense_team_id = .offense_id, defense_team_id = .defense_id,
    period, clock_seconds = .clock_min * 60 + .clock_sec,
    down, distance,
    yard_line = yards_to_goal,
    play_type,
    is_scrimmage_play = !(play_type %in% NON_SCRIMMAGE_TYPES) & !is.na(.offense_id),
    rush_pass = .rush_pass,
    yards_gained,
    epa = .epa,
    success = as.logical(success),
    garbage_time = if_else(
      !is.na(.garbage_time_api), as.logical(.garbage_time_api),
      (period >= 4) & (abs(coalesce(offense_score, 0) - coalesce(defense_score, 0)) >
                          (28 - .clock_min * 1.5))
    )
  )

# `games` (from cfbd_game_info()) is the authoritative FBS schedule for this
# project. cfbd_pbp_data() can return plays for a game_id that never showed
# up there -- most likely an FCS-vs-FCS game, or something outside the
# classification cfbd_game_info() filters to by default. `plays` has a FK to
# `games`, and a game outside our schedule is out of scope for FBS
# predictions anyway, so drop those rows here rather than fabricating a stub
# game the way we did for FCS opponent TEAMS (which we do need, since they
# play FBS teams that ARE in scope).
n_before <- nrow(plays)
plays <- plays %>% filter(game_id %in% games$game_id)
n_dropped <- n_before - nrow(plays)
if (n_dropped > 0) {
  message(sprintf(
    "Dropped %d play(s) belonging to %d game(s) not in the FBS schedule pull (out of scope).",
    n_dropped, length(setdiff(unique(.pbp_game_id), games$game_id))
  ))
}

upsert(plays, "plays", "play_id")

# ---- 3b. Aggregate plays -> game_team_stats (materialized rollup) --------
scrimmage <- plays %>% filter(is_scrimmage_play)

agg_one <- function(df) {
  df %>%
    group_by(game_id, team_id = offense_team_id) %>%
    summarise(
      total_yards = sum(yards_gained, na.rm = TRUE),
      offensive_plays = n(),
      yards_per_play = round(total_yards / pmax(offensive_plays, 1), 3),
      passing_yards = sum(yards_gained[rush_pass == "pass"], na.rm = TRUE),
      rushing_yards = sum(yards_gained[rush_pass == "rush"], na.rm = TRUE),
      epa_total = sum(epa, na.rm = TRUE),
      epa_per_play = round(epa_total / pmax(offensive_plays, 1), 4),
      success_rate = round(mean(success, na.rm = TRUE), 4),
      explosiveness = round(mean(epa[success], na.rm = TRUE), 4),
      .groups = "drop"
    )
}

game_team_stats_all   <- agg_one(scrimmage)
game_team_stats_clean <- agg_one(scrimmage %>% filter(!garbage_time)) %>%
  rename(offensive_plays_ex_garbage = offensive_plays,
         yards_per_play_ex_garbage = yards_per_play,
         epa_per_play_ex_garbage = epa_per_play,
         success_rate_ex_garbage = success_rate) %>%
  select(game_id, team_id, offensive_plays_ex_garbage, yards_per_play_ex_garbage,
         epa_per_play_ex_garbage, success_rate_ex_garbage)

# Box-score fields not derivable from EPA pbp alone (turnovers, 3rd/4th down
# pct, time of possession) still come from cfbd's game-team box score, joined
# on top of the atomic-grain aggregation above.
#
# cfbd_game_team_stats() rejects a whole-season pull with HTTP 400 -- it
# requires `week` alongside `year` (can't ask for every week's box scores in
# one call, unlike cfbd_game_info()/cfbd_pbp_data()). Loop over every
# (season_type, week) combination that actually has a completed game, same
# per-week pattern the ratings pull uses further down.
completed_weeks <- games %>% filter(completed) %>% distinct(season_type, week)
box_raw <- if (nrow(completed_weeks) == 0) {
  data.frame()
} else {
  purrr::pmap_dfr(completed_weeks, function(season_type, week) {
    tryCatch(
      cfbd_game_team_stats(year = SEASON, week = week, season_type = season_type),
      error = function(e) {
        message(sprintf("No team box-score data for week %s (%s) -- skipping.", week, season_type))
        NULL
      }
    )
  })
}

# Column names on this endpoint are exactly the kind that have burned us
# before (offense_id vs offense_team_id, etc.) -- wrap the whole mapping in a
# tryCatch so an unexpected column name degrades gracefully (box-score
# fields come back NA, atomic-grain fields from `plays` are unaffected)
# instead of crashing the entire ingest run over one non-critical join.
# Column names on this endpoint turned out to differ substantially from the
# guessed mapping (confirmed via dplyr::glimpse(box_raw)):
#   - no team_id/opponent_id at all -- only `school`/`opponent` name strings,
#     so team_id has to come from a name lookup against `teams` instead.
#   - third_down_eff/fourth_down_eff are composite "made-attempted" strings
#     (e.g. "5-14"), not separate numeric columns.
#   - possession_time is a "MM:SS" string, not seconds.
#   - no havoc_total field on this endpoint at all -- left NA here; would
#     need a separate defensive-metrics pull to fill in later if wanted.

# parse_frac <- function(x) {
#   parts <- strsplit(x, "-", fixed = TRUE)
#   list(
#     made = vapply(parts, function(p) if (length(p) == 2) as.numeric(p[1]) else NA_real_, numeric(1)),
#     att  = vapply(parts, function(p) if (length(p) == 2) as.numeric(p[2]) else NA_real_, numeric(1))
#   )
# }
# parse_mmss <- function(x) {
#   parts <- strsplit(x, ":", fixed = TRUE)
#   vapply(parts, function(p) {
#     if (length(p) == 2) as.numeric(p[1]) * 60 + as.numeric(p[2]) else NA_real_
#   }, numeric(1))
# }
#####################################################################################
parse_frac <- function(x) {
  parts <- strsplit(as.character(x), "-", fixed = TRUE)
  list(
    made = vapply(parts, function(p) if (length(p) == 2) as.numeric(p[1]) else NA_real_, numeric(1)),
    att  = vapply(parts, function(p) if (length(p) == 2) as.numeric(p[2]) else NA_real_, numeric(1))
  )
}

parse_mmss <- function(x) {
  parts <- strsplit(as.character(x), ":", fixed = TRUE)
  vapply(parts, function(p) {
    if (length(p) == 2) as.numeric(p[1]) * 60 + as.numeric(p[2]) else NA_real_
  }, numeric(1))
}

######################################################################################
box_extra <- tryCatch({
  if (nrow(box_raw) == 0 || !has_col(box_raw, "school")) stop("no box-score rows available")
  
  team_lookup <- dbGetQuery(con, "SELECT team_id, school FROM teams;")
  team_lookup_opp <- team_lookup %>% rename(opponent_id = team_id, opponent = school)
  
  third_down  <- parse_frac(get_col(box_raw, "third_down_eff"))
  fourth_down <- parse_frac(get_col(box_raw, "fourth_down_eff"))
  poss_sec    <- parse_mmss(get_col(box_raw, "possession_time"))
  
  # Defensive unlist helper for potential list-cols from pivot warnings
  flatten_col <- function(df, col_name) {
    v <- get_col(df, col_name)
    if (is.list(v)) v <- vapply(v, function(x) if (length(x) > 0) as.numeric(x[1]) else NA_real_, numeric(1))
    suppressWarnings(as.numeric(v))
  }
  
  matched <- box_raw %>%
    mutate(
      .third_made = third_down$made, .third_att = third_down$att,
      .fourth_made = fourth_down$made, .fourth_att = fourth_down$att,
      .poss_sec = poss_sec,
      .turnovers = flatten_col(box_raw, "turnovers"),
      .fumbles_lost = flatten_col(box_raw, "fumbles_lost"),
      .passes_intercepted = flatten_col(box_raw, "passes_intercepted")
    ) %>%
    left_join(team_lookup, by = "school") %>%
    left_join(team_lookup_opp, by = "opponent") %>%
    transmute(
      game_id = as.integer(game_id), team_id, opponent_id,
      is_home = (home_away == "home"),
      points = suppressWarnings(as.numeric(points)),
      turnovers = .turnovers,
      fumbles_lost = .fumbles_lost,
      interceptions_thrown = .passes_intercepted,
      third_down_pct = .third_made / pmax(.third_att, 1),
      fourth_down_pct = .fourth_made / pmax(.fourth_att, 1),
      time_of_possession_sec = .poss_sec,
      havoc_rate = NA_real_
    )
  
  matched
}, error = function(e) {
  message(sprintf("Box-score join skipped (%s) -- deriving schedule metadata from `games`.", conditionMessage(e)))
  data.frame(game_id = numeric(0), team_id = integer(0), opponent_id = integer(0), is_home = logical(0))
})
#######################################################################################

# game_team_stats <- game_team_stats_all %>%
#  left_join(game_team_stats_clean, by = c("game_id", "team_id")) %>%
#  left_join(box_extra, by = c("game_id", "team_id")) %>%
#  relocate(game_id, team_id, opponent_id, is_home)

# upsert(game_team_stats, "game_team_stats", "game_id, team_id")
# upsert(game_team_stats, "game_team_stats", c("game_id", "team_id"))
#######################################################################################

# Derive game sides directly from authoritative games schedule table
game_sides <- games %>%
  select(game_id, home_team_id, away_team_id) %>%
  pivot_longer(cols = c(home_team_id, away_team_id), names_to = "side", values_to = "team_id") %>%
  mutate(
    opponent_id = if_else(side == "home_team_id", 
                          games$away_team_id[match(game_id, games$game_id)], 
                          games$home_team_id[match(game_id, games$game_id)]),
    is_home = (side == "home_team_id")
  ) %>%
  select(game_id, team_id, opponent_id, is_home)

# Construct final staging frame
game_team_stats <- game_sides %>%
  inner_join(game_team_stats_all, by = c("game_id", "team_id")) %>%
  left_join(game_team_stats_clean, by = c("game_id", "team_id")) %>%
  left_join(box_extra %>% select(-any_of(c("opponent_id", "is_home"))), by = c("game_id", "team_id")) %>%
  relocate(game_id, team_id, opponent_id, is_home)

# Execute upsert safely
upsert(game_team_stats, "game_team_stats", c("game_id", "team_id"))

########################################################################################

# ---- 4. Weekly ratings: Elo, FPI, SP+ -------------------------------------
# None of these three endpoints return team_id -- only a `team` name string,
# same shape as the box-score endpoint above (confirmed via
# dplyr::glimpse()). Their real offense/defense field names also differ.
#  SP+ uses offense_rating/defense_rating (not # offense/defense); 
#  FPI uses efficiencies_offense/efficiencies_defense, which
# come back NA this early in the season -- that's genuinely sparse data, not
# a bug, and will populate as the season progresses. Elo has no
# offense/defense split at all. Resolve team_id by name against `teams`,
# same pattern as the box-score join.
rating_team_lookup <- dbGetQuery(con, "SELECT team_id, school FROM teams;")

# cfbd's elo/fpi/sp endpoints are season-to-date snapshots when called with
# `week=`; loop across completed weeks to build the weekly history table.
current_week <- max(games$week[games$completed], 0, na.rm = TRUE)
ratings_weekly <- map_dfr(0:current_week, function(w) {
  e <- tryCatch(cfbd_ratings_elo(year = SEASON, week = w), error = function(e) NULL)
  f <- tryCatch(cfbd_ratings_fpi(year = SEASON), error = function(e) NULL) # FPI has no week param; latest snapshot
  s <- tryCatch(cfbd_ratings_sp(year = SEASON, week = w), error = function(e) NULL)
  if (is.null(e)) return(NULL)

  out <- e %>% left_join(rating_team_lookup, by = c("team" = "school"))

  out <- if (!is.null(f) && has_col(f, "team")) {
    out %>% left_join(
      f %>% transmute(
        team,
        fpi_rating = fpi,
        fpi_offense = suppressWarnings(as.numeric(get_col(f, "efficiencies_offense"))),
        fpi_defense = suppressWarnings(as.numeric(get_col(f, "efficiencies_defense")))
      ),
      by = "team"
    )
  } else {
    out %>% mutate(fpi_rating = NA_real_, fpi_offense = NA_real_, fpi_defense = NA_real_)
  }

  out <- if (!is.null(s) && has_col(s, "team")) {
    out %>% left_join(
      s %>% transmute(
        team, sp_plus_rating = rating,
        sp_plus_offense = get_col(s, "offense_rating"),
        sp_plus_defense = get_col(s, "defense_rating")
      ),
      by = "team"
    )
  } else {
    out %>% mutate(sp_plus_rating = NA_real_, sp_plus_offense = NA_real_, sp_plus_defense = NA_real_)
  }

  out %>%
    transmute(
      season = SEASON, week = w, team_id,
      elo_rating = elo, fpi_rating, fpi_offense, fpi_defense,
      sp_plus_rating, sp_plus_offense, sp_plus_defense,
      srs_rating = NA_real_
    )
})

# team_id is part of team_week_ratings' primary key, so an unmatched name
# (spelling mismatch between this endpoint and `teams`) can't be inserted --
# drop those rows and say so, rather than let the whole upsert fail.
n_unmatched_ratings <- sum(is.na(ratings_weekly$team_id))
if (n_unmatched_ratings > 0) {
  message(sprintf(
    "%d of %d weekly rating row(s) didn't name-match a team in `teams` -- dropped.",
    n_unmatched_ratings, nrow(ratings_weekly)
  ))
  ratings_weekly <- ratings_weekly %>% filter(!is.na(team_id))
}

upsert(ratings_weekly, "team_week_ratings", "season, week, team_id")

################################################################################
# ---- 5. Betting lines ------------------------------------------------------
dbExecute(con, "SET search_path TO cfb2026, public;")
lines_raw <- cfbd_betting_lines(year = SEASON)

lines <- lines_raw %>%
  transmute(
    game_id = as.integer(game_id), 
    provider = provider,
    spread = as.numeric(spread), 
    over_under = as.numeric(over_under),
    home_moneyline = as.numeric(home_moneyline), 
    away_moneyline = as.numeric(away_moneyline),
    pulled_at = Sys.time()  # Satisfies the primary key requirement
  ) %>%
  filter(!is.na(spread)) %>%
  # Keep only the latest line per provider per game if duplicates exist in lines_raw
  group_by(game_id, provider) %>%
  slice_max(order_by = pulled_at, n = 1, with_ties = FALSE) %>%
  ungroup()

# Scope check against games schedule table
n_before <- nrow(lines)
lines <- lines %>% filter(game_id %in% games$game_id)
n_dropped <- n_before - nrow(lines)

if (n_dropped > 0) {
  message(sprintf(
    "Dropped %d betting line(s) for game(s) not in the FBS schedule pull (out of scope).",
    n_dropped
  ))
}

# Execute upsert across composite primary key
upsert(lines, "betting_lines", c("game_id", "provider", "pulled_at"))

################################################################################

################################################################################


bline <- dbGetQuery(con, "
  SELECT table_schema, table_name 
  FROM information_schema.tables 
  WHERE table_name = 'betting_lines';
")
                
bline

dbDisconnect(con)
message(glue("Ingest complete for season {SEASON}, through week {current_week}."))


