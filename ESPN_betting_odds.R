library(httr2)
library(jsonlite)
library(dplyr)
library(purrr)

# Set working directory
setwd("/home/jack/Documents/cfb2026/file_18/workflow")

# ESPN's public College Football scoreboard API endpoint
url <- "https://site.api.espn.com/apis/site/v2/sports/football/college-football/scoreboard"

# Query parameters for Week 2 & higher page limit
res <- request(url) |> 
  req_url_query(
    week = 2,          # Fetch Week 2 specifically
    groups = 80,       # 80 = FBS (Use 50 for ALL Division I including FCS)
    limit = 300        # Increase limit from default 25 to 300 to capture all games
  ) |> 
  req_perform() |> 
  resp_body_json()

# Extract games and consensus betting odds safely
odds_df <- map_df(res$events, function(event) {
  competition <- event$competitions[[1]]
  
  # Competitors (Teams)
  home_team <- competition$competitors[[1]]$team$displayName
  away_team <- competition$competitors[[2]]$team$displayName
  
  # Safe extraction of odds list (handles games with no lines posted yet)
  odds_list <- competition$odds
  odds_data <- if (length(odds_list) > 0) odds_list[[1]] else list()
  
  tibble(
    game_id = event$id,
    game_date = event$date,
    home_team = home_team,
    away_team = away_team,
    details = odds_data$details %||% NA_character_,
    over_under = odds_data$overUnder %||% NA_real_,
    spread = odds_data$spread %||% NA_real_
  )
})

print(odds_df, n = Inf)



library(readr)

# Write to CSV using readr (faster, clean formatting)
write_csv(odds_df, "week2_odds.csv")

# Alternatively, using base R:
# write.csv(odds_df, "week2_odds.csv", row.names = FALSE)


library(readr)

# Write to TSV using readr
write_tsv(odds_df, "week2_odds.tsv")

# Alternatively, using base R:
# write.table(odds_df, "week2_odds.tsv", sep = "\t", row.names = FALSE, quote = FALSE)
