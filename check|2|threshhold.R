# Check |2| threshold

# con <- dbConnect(Postgres(), ...)   # reuse your existing connection params

con <- dbConnect(
  RPostgres::Postgres(),
  dbname = "tsdb",
  host = "localhost",
  port = 5432,
  user = "jack",
  password = "StCroixRiver"
)

library(DBI)
library(RPostgres)
library(dplyr)
library(tidyr)
library(ggplot2)

# --- Config ------------------------------------------------------------
threshold <- 4   # like-to-like games needed per team (~320 plays @ ~80/game)

# --- Pull completed games -------------------------------------------------


feat <- dbGetQuery(con, "
  SELECT game_id, season, week, home_team_id, home_school, home_tier,
         away_team_id, away_school, away_tier, like_to_like
  FROM cfb2026.v_game_features
  WHERE actual_spread IS NOT NULL
")
dbDisconnect(con)

# --- Reshape to one row per team per game --------------------------------
team_games <- bind_rows(
  feat %>% transmute(team_id = home_team_id, school = home_school,
                     tier = home_tier, week, like_to_like),
  feat %>% transmute(team_id = away_team_id, school = away_school,
                     tier = away_tier, week, like_to_like)
) %>%
  arrange(team_id, week)

# Cumulative like-to-like count per team, in week order
team_progress <- team_games %>%
  group_by(team_id, school, tier) %>%
  arrange(week, .by_group = TRUE) %>%
  mutate(cum_l2l = cumsum(like_to_like)) %>%
  ungroup()

# --- Current status per team ---------------------------------------------
first_reliable_week <- team_progress %>%
  filter(cum_l2l >= threshold) %>%
  group_by(team_id, school) %>%
  summarise(week_reliable = min(week), .groups = "drop")

team_status <- team_progress %>%
  group_by(team_id, school, tier) %>%
  summarise(games_played = n(),
            l2l_games    = sum(like_to_like),
            latest_week  = max(week),
            reliable     = l2l_games >= threshold,
            .groups = "drop") %>%
  left_join(first_reliable_week, by = c("team_id", "school")) %>%
  arrange(desc(reliable), desc(l2l_games))

current_week <- max(feat$week)
message(sprintf(
  "Week %d: %.0f%% of tracked teams have %d+ like-to-like games",
  current_week, 100 * mean(team_status$reliable), threshold
))

# --- Week-by-week % reliable, by tier (P4 vs G5) --------------------------
week_range <- 0:current_week

grid <- team_progress %>%
  distinct(team_id, school, tier) %>%
  crossing(week = week_range) %>%
  left_join(team_progress %>% select(team_id, week, cum_l2l),
            by = c("team_id", "week")) %>%
  arrange(team_id, week) %>%
  group_by(team_id) %>%
  fill(cum_l2l, .direction = "down") %>%
  mutate(cum_l2l = replace_na(cum_l2l, 0)) %>%
  ungroup()

tier_week_summary <- grid %>%
  group_by(tier, week) %>%
  summarise(pct_reliable = mean(cum_l2l >= threshold), .groups = "drop")

print(
  tier_week_summary %>% pivot_wider(names_from = tier, values_from = pct_reliable),
  n = Inf
)

# --- Visual: when does each tier cross the reliable window? ---------------
ggplot(tier_week_summary, aes(week, pct_reliable, color = tier)) +
  geom_line(linewidth = 1) +
  geom_point() +
  geom_hline(yintercept = 0.9, linetype = "dashed", alpha = 0.5) +
  scale_y_continuous(labels = scales::percent, limits = c(0, 1)) +
  labs(title = sprintf("Share of teams with %d+ like-to-like games, by week", threshold),
       x = "Week", y = "% of teams reliable", color = "Tier",
       caption = "Dashed line = 90% of tier reliable") +
  theme_minimal()

# --- Full team-level detail (for spot-checking) ---------------------------

class(team_status)
# View(team_status)
team_status
# Print all sorted unique values in a character vector
sort(unique(team_status$school))

# Print all rows of a data frame/tibble
team_status %>% 
  select(school) %>% 
  arrange(school) %>% 
  print(n = Inf)

# Count occurrences of each status
team_status %>% 
  count(school) %>% 
  print(n = Inf)

