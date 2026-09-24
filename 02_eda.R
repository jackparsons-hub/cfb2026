# ==============================================================================
# 02_eda.R
# EDA on the historical + current-season data pulled into Postgres.
# Produces: distribution plots, home-field-advantage estimate, correlation of
# each candidate predictor with actual spread, missingness report, and a
# stationarity/autocorrelation check on team-level rating trajectories
# (informs whether recurrent models need differencing).
# ==============================================================================

library(DBI); 
library(RPostgres); 
library(dplyr); 
library(ggplot2)
library(tidyr); 
library(corrr); 
library(tseries)

con <- dbConnect(RPostgres::Postgres(),
                  host = Sys.getenv("PGHOST","localhost"), dbname = Sys.getenv("PGDATABASE","tsdb"),
                  user = Sys.getenv("PGUSER","jack"), password = Sys.getenv("PASSWORD","StCroixRiver"))

feat <- dbGetQuery(con, "SELECT * FROM cfb2026.v_game_features WHERE actual_spread IS NOT NULL;")
dbDisconnect(con)

# --- 1. Missingness report --------------------------------------------------
missing_report <- feat %>%
  summarise(across(everything(), ~ mean(is.na(.)))) %>%
  pivot_longer(everything(), names_to = "field", values_to = "pct_missing") %>%
  arrange(desc(pct_missing))
print(missing_report, n = 30)

# --- 2. Home-field advantage (raw mean margin for non-neutral games) --------
hfa <- feat %>% filter(!neutral_site) %>% summarise(hfa_points = mean(actual_spread, na.rm = TRUE))
message(sprintf("Estimated home-field advantage: %.2f points", hfa$hfa_points))

# --- 3. Predictor correlation with actual spread ----------------------------
corr_tbl <- feat %>%
  transmute(
    actual_spread,
    elo_diff = home_elo - away_elo,
    fpi_diff = home_fpi - away_fpi,
    sp_plus_diff = home_sp_plus - away_sp_plus,
    vegas_spread = -vegas_spread   # convert to home-minus-away convention if needed
  ) %>%
  drop_na() %>%
  correlate() %>%
  focus(actual_spread)
print(corr_tbl)

# --- 4. Distribution plots --------------------------------------------------
ggsave("eda_spread_distribution.png",
       ggplot(feat, aes(actual_spread)) + geom_histogram(binwidth = 3) +
         labs(title = "Distribution of actual point differential (home - away)"),
       width = 7, height = 4)

ggsave("eda_vegas_vs_actual.png",
       ggplot(feat %>% drop_na(vegas_spread), aes(x = -vegas_spread, y = actual_spread)) +
         geom_point(alpha = 0.3) + geom_abline(slope = 1, intercept = 0, color = "red") +
         labs(title = "Vegas closing spread vs. actual margin", x = "Vegas (home-perspective)", y = "Actual margin"),
       width = 7, height = 5)

# --- 5. Autocorrelation / stationarity check on Elo trajectories ------------
# Pick a sample team to sanity-check whether rating series need differencing
# before feeding a recurrent model (drives whether we model levels or deltas).
sample_series <- feat %>% filter(home_school == "Ohio State") %>% arrange(week) %>% pull(home_elo)
if (length(na.omit(sample_series)) > 8) {
  adf <- suppressWarnings(adf.test(na.omit(sample_series)))
  message(sprintf("ADF test p-value on sample Elo series: %.3f (>0.05 suggests using deltas, not levels)", adf$p.value))
}

message("EDA complete. Review eda_spread_distribution.png, eda_vegas_vs_actual.png, and printed tables above.")
