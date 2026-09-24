SHOW hba_file;
-- ============================================================================
-- CFB2026 :: PostgreSQL Schema
-- Source of truth for CFBfastR-pulled NCAA FBS data, engineered features,
-- ratings (Elo/FPI/SP+), betting lines, model runs, and predictions.
-- Grain: teams, games (week-level), per-team-per-game stats, and weekly
-- team ratings snapshots (so Elo/FPI history is queryable week-over-week).
-- ============================================================================

CREATE SCHEMA IF NOT EXISTS cfb2026;
SET search_path TO cfb2026, public;

-- ----------------------------------------------------------------------------
-- Reference: conference_tier_map -- classifies each conference as Power Four
-- or Group of Five for "like-to-like" filtering. FBS independents (Notre Dame,
-- UConn, UMass, etc.) don't belong to either bucket by conference alone, so
-- they're classified individually via teams.tier_override below rather than
-- guessed from conference name.
-- ----------------------------------------------------------------------------
DROP TABLE conference_tier_map;
CREATE TABLE IF NOT EXISTS conference_tier_map (
    conference  TEXT PRIMARY KEY,
    tier        TEXT NOT NULL CHECK (tier IN ('P4','G5'))
);
INSERT INTO conference_tier_map (conference, tier) VALUES
    ('ACC','P4'), ('Big 12','P4'), ('Big Ten','P4'), ('SEC','P4'),
    ('American Athletic','G5'), ('Conference USA','G5'),
    ('Mid-American','G5'), ('Mountain West','G5'), ('Sun Belt','G5')
ON CONFLICT (conference) DO NOTHING;

-- ----------------------------------------------------------------------------
-- Reference: teams
-- ----------------------------------------------------------------------------
DROP TABLE teams;
CREATE TABLE IF NOT EXISTS teams (
    team_id         INTEGER PRIMARY KEY,          -- cfbd school_id
    school          TEXT NOT NULL,
    conference      TEXT,
    division        TEXT,                          -- e.g. 'FBS'
    classification  TEXT,                          -- fbs/fcs
    color           TEXT,
    alt_color       TEXT,
    logo_url        TEXT,
    logo_url_alt    TEXT,                          -- cfbd's secondary logo (logo_2)
    -- Manual override for FBS independents and any team whose conference name
    -- doesn't map cleanly (e.g. Notre Dame -> 'P4', UConn/UMass -> 'G5').
    -- Populate by hand in seed data; NULL falls back to conference_tier_map.
    tier_override   TEXT CHECK (tier_override IN ('P4','G5')),
    updated_at      TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- Resolved tier per team: override wins, else looked up from conference.
DROP TABLE v_team_tier;
CREATE OR REPLACE VIEW v_team_tier AS
SELECT t.team_id, t.school, t.conference,
       COALESCE(t.tier_override, ctm.tier) AS tier   -- NULL = unclassified (e.g. FCS)
FROM teams t
LEFT JOIN conference_tier_map ctm ON ctm.conference = t.conference;

-- ----------------------------------------------------------------------------
-- games: one row per scheduled/played FBS (or FBS-vs-FCS) contest
-- ----------------------------------------------------------------------------
DROP TABLE games;
CREATE TABLE IF NOT EXISTS games (
    game_id             BIGINT PRIMARY KEY,        -- cfbd game id
    season              SMALLINT NOT NULL,
    week                SMALLINT NOT NULL,          -- 0 = Week 0
    season_type         TEXT NOT NULL,              -- regular/postseason
    start_date          TIMESTAMPTZ,
    neutral_site        BOOLEAN DEFAULT FALSE,
    conference_game     BOOLEAN DEFAULT FALSE,
    venue_id            INTEGER,
    home_team_id        INTEGER NOT NULL REFERENCES teams(team_id),
    away_team_id        INTEGER NOT NULL REFERENCES teams(team_id),
    home_points         SMALLINT,                   -- NULL until played
    away_points         SMALLINT,
    home_line_scores    SMALLINT[],                 -- per-quarter, optional
    away_line_scores    SMALLINT[],
    completed           BOOLEAN NOT NULL DEFAULT FALSE,
    excitement_index    NUMERIC(6,3),
    updated_at          TIMESTAMPTZ NOT NULL DEFAULT now(),
    UNIQUE (season, week, home_team_id, away_team_id)
);
DROP INDEX idx_games_season_week;
CREATE INDEX IF NOT EXISTS idx_games_season_week ON games(season, week);
DROP INDEX idx_games_home;
CREATE INDEX IF NOT EXISTS idx_games_home ON games(home_team_id);
DROP INDEX idx_games_away;
CREATE INDEX IF NOT EXISTS idx_games_away ON games(away_team_id);

-- ----------------------------------------------------------------------------
-- v_games_tiered: a game is "like-to-like" only if BOTH teams resolve to the
-- SAME tier (P4-vs-P4 or G5-vs-G5). Cross-tier games (P4 vs G5), and any game
-- involving an unclassified team (FCS, or an independent with no override
-- set), are like_to_like = FALSE and should be excluded from tier-level
-- rating/form calculations.
-- ----------------------------------------------------------------------------
DROP TABLE v_games_tiered;
CREATE OR REPLACE VIEW v_games_tiered AS
SELECT g.*, ht.tier AS home_tier, at.tier AS away_tier,
       (ht.tier IS NOT NULL AND ht.tier = at.tier) AS like_to_like
FROM games g
JOIN v_team_tier ht ON ht.team_id = g.home_team_id
JOIN v_team_tier at ON at.team_id = g.away_team_id;

-- Running count of like-to-like games played per team per season -- lets you
-- see, e.g., "Boise State has played 6 like-to-like (G5) games this season"
-- and gate any model/rating that requires a minimum like-to-like sample.
DROP TABLE v_team_like_to_like_counts;
CREATE OR REPLACE VIEW v_team_like_to_like_counts AS
SELECT team_id, season, tier, COUNT(*) AS like_to_like_games_played
FROM (
    SELECT home_team_id AS team_id, season, home_tier AS tier FROM v_games_tiered WHERE like_to_like AND completed
    UNION ALL
    SELECT away_team_id AS team_id, season, away_tier AS tier FROM v_games_tiered WHERE like_to_like AND completed
) x
GROUP BY team_id, season, tier;

-- ----------------------------------------------------------------------------
-- plays: ATOMIC GRAIN. One row per snap. Every per-game/per-team stat below
-- (yards-per-play, EPA/play, success rate, explosiveness) is computed by
-- aggregating THIS table, never taken pre-aggregated from a box score --
-- that's what makes a 60-play team and a 100-play team comparable: every
-- rate stat is plays_summed / plays_counted, not a box-score total divided
-- by a play count nobody re-derives.
-- ----------------------------------------------------------------------------
DROP TABLE plays;
CREATE TABLE IF NOT EXISTS plays (
    play_id             BIGINT PRIMARY KEY,          -- cfbd play id
    game_id              BIGINT NOT NULL REFERENCES games(game_id),
    offense_team_id      INTEGER NOT NULL REFERENCES teams(team_id),
    defense_team_id      INTEGER NOT NULL REFERENCES teams(team_id),
    period               SMALLINT,
    clock_seconds         INTEGER,                    -- seconds remaining in period
    down                 SMALLINT,
    distance             SMALLINT,
    yard_line            SMALLINT,
    play_type            TEXT,                        -- cfbd's raw play_type string
    -- is_scrimmage_play = TRUE for rush/pass/sack plays that count toward an
    -- offensive-plays denominator; FALSE for kickoffs, punts, FG/PAT,
    -- penalties with no play, timeouts, and end-of-period markers.
    is_scrimmage_play    BOOLEAN NOT NULL DEFAULT FALSE,
    rush_pass            TEXT CHECK (rush_pass IN ('rush','pass','other')),
    yards_gained         INTEGER,
    epa                  NUMERIC(6,3),
    success              BOOLEAN,                     -- cfbd success-rate definition (down/distance-based)
    garbage_time         BOOLEAN DEFAULT FALSE         -- score-differential/clock-based flag; excluded from ratings by default
);
DROP INDEX idx_plays_game;
CREATE INDEX IF NOT EXISTS idx_plays_game ON plays(game_id);
DROP INDEX idx_plays_offense;
CREATE INDEX IF NOT EXISTS idx_plays_offense ON plays(offense_team_id);
DROP INDEX idx_plays_scrimmage;
CREATE INDEX IF NOT EXISTS idx_plays_scrimmage ON plays(game_id, offense_team_id) WHERE is_scrimmage_play;

-- ----------------------------------------------------------------------------
-- game_team_stats: one row per team per game. Populated by AGGREGATING the
-- `plays` table (see 01_ingest_cfbfastr.R), not from cfbd's pre-baked
-- game-team box score -- this table is a materialized rollup, plays is the
-- source of truth.
-- ----------------------------------------------------------------------------
DROP TABLE game_team_stats;
CREATE TABLE IF NOT EXISTS game_team_stats (
    game_id             BIGINT NOT NULL REFERENCES games(game_id),
    team_id             INTEGER NOT NULL REFERENCES teams(team_id),
    opponent_id          INTEGER NOT NULL REFERENCES teams(team_id),
    is_home              BOOLEAN NOT NULL,
    points               SMALLINT,
    total_yards          INTEGER,                     -- SUM(yards_gained) over scrimmage plays
    offensive_plays      INTEGER,                     -- COUNT(*) of scrimmage plays -- the atomic denominator
    yards_per_play       NUMERIC(6,3),                -- total_yards / offensive_plays (all downstream rate stats follow this pattern)
    passing_yards        INTEGER,
    rushing_yards         INTEGER,
    turnovers            SMALLINT,
    fumbles_lost         SMALLINT,
    interceptions_thrown SMALLINT,
    third_down_pct       NUMERIC(5,4),
    fourth_down_pct      NUMERIC(5,4),
    time_of_possession_sec INTEGER,
    epa_total            NUMERIC(8,3),               -- SUM(epa) over scrimmage plays
    epa_per_play         NUMERIC(6,4),                -- epa_total / offensive_plays
    success_rate         NUMERIC(5,4),                -- COUNT(success) / offensive_plays
    explosiveness         NUMERIC(6,4),                -- mean EPA of successful plays only
    havoc_rate            NUMERIC(5,4),
    -- Non-garbage-time versions of the same rate stats -- garbage-time snaps
    -- (usually running-clock, large-lead situations) inflate/deflate per-play
    -- averages unevenly across blowout-prone P4-vs-G5 games; keep both so
    -- like-to-like comparisons can use whichever is more appropriate.
    offensive_plays_ex_garbage  INTEGER,
    yards_per_play_ex_garbage   NUMERIC(6,3),
    epa_per_play_ex_garbage     NUMERIC(6,4),
    success_rate_ex_garbage     NUMERIC(5,4),
    PRIMARY KEY (game_id, team_id)
);
DROP INDEX idx_gts_team;
CREATE INDEX IF NOT EXISTS idx_gts_team ON game_team_stats(team_id);

-- Running per-team play history: cumulative like-to-like offensive plays
-- and like-to-like games THROUGH each played week. Used at prediction time
-- to look up how sampled a team was heading into a future week (take the
-- latest row with week < target week). Placed here, after game_team_stats,
-- since it's the table this view aggregates -- a view can't reference a
-- table that doesn't exist yet.
DROP TABLE v_team_play_history;
CREATE OR REPLACE VIEW v_team_play_history AS
SELECT s.team_id, g.season, g.week,
       SUM(s.offensive_plays) OVER (PARTITION BY s.team_id, g.season ORDER BY g.week) AS cumulative_plays_through_week,
       COUNT(*) OVER (PARTITION BY s.team_id, g.season ORDER BY g.week) AS like_to_like_games_through_week
FROM game_team_stats s
JOIN games g ON g.game_id = s.game_id
JOIN v_games_tiered gt ON gt.game_id = g.game_id
WHERE gt.like_to_like AND g.completed;

-- ----------------------------------------------------------------------------
-- team_week_ratings: weekly snapshot of external ratings (Elo, FPI, SP+)
-- ----------------------------------------------------------------------------
DROP TABLE team_week_ratings;
CREATE TABLE IF NOT EXISTS team_week_ratings (
    season          SMALLINT NOT NULL,
    week            SMALLINT NOT NULL,
    team_id         INTEGER NOT NULL REFERENCES teams(team_id),
    elo_rating      NUMERIC(7,2),
    fpi_rating      NUMERIC(6,3),
    fpi_offense     NUMERIC(6,3),
    fpi_defense     NUMERIC(6,3),
    sp_plus_rating  NUMERIC(6,3),
    sp_plus_offense NUMERIC(6,3),
    sp_plus_defense NUMERIC(6,3),
    srs_rating      NUMERIC(6,3),
    pulled_at       TIMESTAMPTZ NOT NULL DEFAULT now(),
    PRIMARY KEY (season, week, team_id)
);

-- ----------------------------------------------------------------------------
-- betting_lines: sportsbook lines per game, as pulled from cfbd_betting_lines
-- ----------------------------------------------------------------------------
DROP TABLE betting_lines;
CREATE TABLE IF NOT EXISTS betting_lines (
    game_id         BIGINT NOT NULL REFERENCES games(game_id),
    provider        TEXT NOT NULL,                  -- e.g. 'ESPN Bet', 'Bovada', 'consensus'
    spread          NUMERIC(5,1),                    -- home-team spread convention
    over_under      NUMERIC(5,1),
    home_moneyline  INTEGER,
    away_moneyline  INTEGER,
    pulled_at       TIMESTAMPTZ NOT NULL DEFAULT now(),
    PRIMARY KEY (game_id, provider, pulled_at)
);

-- ----------------------------------------------------------------------------
-- model_runs: metadata for each trained model (Elo-logit, XGB, GRU, LSTM, Transformer)
-- ----------------------------------------------------------------------------
DROP TABLE model_runs;
CREATE TABLE IF NOT EXISTS model_runs (
    run_id              BIGSERIAL PRIMARY KEY,
    model_name          TEXT NOT NULL,               -- 'gru','lstm','transformer','xgboost','elo_logit'
    model_version       TEXT NOT NULL,
    trained_at          TIMESTAMPTZ NOT NULL DEFAULT now(),
    train_window_start  SMALLINT,                    -- season
    train_window_end    SMALLINT,
    hyperparams         JSONB,
    notes               TEXT
);

-- ----------------------------------------------------------------------------
-- predictions: per-game, per-model predicted outcomes
-- ----------------------------------------------------------------------------
DROP TABLE predictions;
CREATE TABLE IF NOT EXISTS predictions (
    run_id                  BIGINT NOT NULL REFERENCES model_runs(run_id),
    game_id                 BIGINT NOT NULL REFERENCES games(game_id),
    predicted_home_points   NUMERIC(5,2),
    predicted_away_points   NUMERIC(5,2),
    predicted_spread        NUMERIC(5,2),            -- home - away, negative = home favored
    predicted_home_win_prob NUMERIC(5,4),
    -- Confidence, driven by how sampled each team was heading into this game
    -- (min of home/away cumulative like-to-like plays -- see v_team_play_history).
    -- Bucket thresholds mirror MIN_SAMPLE_PLAYS (320) from 03_feature_engineering.R:
    -- 'low' < 160 plays (~0-2 games), 'medium' 160-319 (~2-4 games), 'high' >= 320.
    min_cumulative_plays     INTEGER,
    confidence_level         TEXT CHECK (confidence_level IN ('low','medium','high')),
    -- Interval half-width = the bucket-specific spread RMSE from model_eval
    -- (i.e. a 'low' confidence prediction gets a wider band, drawn from how
    -- wrong this model actually was on other low-sample games historically --
    -- not an arbitrary widening).
    predicted_spread_low     NUMERIC(5,2),
    predicted_spread_high    NUMERIC(5,2),
    predicted_at            TIMESTAMPTZ NOT NULL DEFAULT now(),
    PRIMARY KEY (run_id, game_id)
);
DROP TABLE idx_predictio;ns_game;
CREATE INDEX IF NOT EXISTS idx_predictions_game ON predictions(game_id);

-- ----------------------------------------------------------------------------
-- model_eval: backtest / holdout metrics per run
-- ----------------------------------------------------------------------------
DROP TABLE model_eval;
CREATE TABLE IF NOT EXISTS model_eval (
    run_id          BIGINT NOT NULL REFERENCES model_runs(run_id),
    split           TEXT NOT NULL,                   -- 'train','val','test','walk_forward'
    metric_name     TEXT NOT NULL,                   -- 'accuracy','log_loss','brier','spread_mae','spread_rmse'
    metric_value    NUMERIC(10,5),
    PRIMARY KEY (run_id, split, metric_name)
);

-- ----------------------------------------------------------------------------
-- Convenience view: game + both teams' latest pre-game ratings + closing line
-- ----------------------------------------------------------------------------
DROP TABLE v_game_features;
CREATE OR REPLACE VIEW v_game_features AS
SELECT
    g.game_id, g.season, g.week, g.start_date, g.neutral_site, g.conference_game,
    g.home_team_id, ht.school AS home_school, vt_h.tier AS home_tier,
    g.away_team_id, at.school AS away_school, vt_a.tier AS away_tier,
    (vt_h.tier IS NOT NULL AND vt_h.tier = vt_a.tier) AS like_to_like,
    g.home_points, g.away_points,
    (g.home_points - g.away_points) AS actual_spread,
    hr.elo_rating AS home_elo, ar.elo_rating AS away_elo,
    hr.fpi_rating AS home_fpi, ar.fpi_rating AS away_fpi,
    hr.sp_plus_rating AS home_sp_plus, ar.sp_plus_rating AS away_sp_plus,
    bl.spread AS vegas_spread, bl.over_under AS vegas_total
FROM games g
JOIN teams ht ON ht.team_id = g.home_team_id
JOIN teams at ON at.team_id = g.away_team_id
JOIN v_team_tier vt_h ON vt_h.team_id = g.home_team_id
JOIN v_team_tier vt_a ON vt_a.team_id = g.away_team_id
LEFT JOIN team_week_ratings hr ON hr.team_id = g.home_team_id AND hr.season = g.season AND hr.week = g.week
LEFT JOIN team_week_ratings ar ON ar.team_id = g.away_team_id AND ar.season = g.season AND ar.week = g.week
LEFT JOIN LATERAL (
    SELECT spread, over_under FROM betting_lines b
    WHERE b.game_id = g.game_id AND b.provider = 'consensus'
    ORDER BY b.pulled_at DESC LIMIT 1
) bl ON TRUE;
