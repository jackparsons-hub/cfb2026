con <- dbConnect(
  RPostgres::Postgres(),
  dbname = "",
  host = "localhost",
  port = 5432,
  user = "",
  password = ""
)

Sys.setenv(CFBD_API_KEY = "")




library(cfbfastR)
library(cfbplotR)
library(DBI)
library(RPostgres)
library(dplyr)
library(purrr)
library(glue)
library(ggplot2)
library(tidyverse)


################################################################################
#
# PLOT YPP DATA
#
################################################################################

library(readr)


Sys.setenv(CFBD_API_KEY = "")

getwd()
setwd("")

SEASON <- 2026

team_info2026 <- cfbd_team_info()
write.csv(team_info2026,"team_info2026.csv")
# team_info2026 <- read.csv("team_info2026.csv")


team_info_p5 <- team_info2026 %>%
  select(team = school,conference,classification, mascot)%>%
  #filter(conference %in% c("Big Ten"))
  filter(conference %in% c("Pac-12","ACC","SEC","Big Ten","Big 12","FBS Independents"))
#filter(classification %in% c("fbs","fcs"))

pbp_raw <- cfbd_pbp_data(year = SEASON, season_type = "both", epa_wpa = TRUE)

write.csv(pbp_raw,"pbp_raw_week3.csv")

# team_info_p5 %>% print(n = Inf)

# Offense - ypp rush and ypp pass
team_plot_off_data_p5 <- pbp_raw %>%
  group_by(team = offense_play) %>%
  summarize(rush_ypp = mean(if_else(rush == 1,yards_gained,NA_real_),na.rm = TRUE),
            n_rush = sum(rush),
            pass_ypp = mean(if_else(pass == 1,yards_gained,NA_real_),na.rm = TRUE),
            n_pass = sum(pass)) %>%
  filter(team %in% team_info_p5$team) %>%
  left_join(team_info_p5,by = "team")

getwd()
write.csv(team_plot_off_data_p5,"team_plot_p4_off_ypp_wk3.csv")

head(team_plot_off_data_p5)


ggplot(team_plot_off_data_p5, aes(x = pass_ypp, y = rush_ypp)) +
  geom_median_lines(aes(x0 = pass_ypp, y0 = rush_ypp)) +
  geom_cfb_logos(aes(team = team), width = 0.075) +
  labs(
    x = "YPP per Pass",
    y = "YPP per Rush",
    title = "Offensive YPP for Rush & Pass - 2026 Week 3"
  ) +
  theme_bw()

# Defense - ypp rush and ypp pass
names(pbp_raw)
names(team_plot_off_data_p5)
pbp_raw %>% select(contains("team"))%>%
  distinct("team")


pbp_raw %>% select(pos_team, def_pos_team) %>% distinct()
pbp_raw %>% select(pos_team, def_pos_team) %>% distinct()
tibble(
  team = sort(unique(c(pbp_raw$pos_team, pbp_raw$def_pos_team)))
) %>% 
  drop_na()

team_plot_def_data_p5 <- pbp_raw %>%
  group_by(team = defense_play) %>%
  summarize(rush_ypp = mean(if_else(rush == 1,yards_gained,NA_real_),na.rm = TRUE),
            n_rush = sum(rush),
            pass_ypp = mean(if_else(pass == 1,yards_gained,NA_real_),na.rm = TRUE),
            n_pass = sum(pass)) %>%
  filter(team %in% team_info_p5$team) %>%
  left_join(team_info_p5,by = "team")

ggplot(team_plot_def_data_p5, aes(x = pass_ypp, y = rush_ypp)) +
  geom_median_lines(aes(x0 = pass_ypp, y0 = rush_ypp)) +
  geom_cfb_logos(aes(team = team), width = 0.075) +
  labs(x = "def ypp per Pass",y = "def ypp per Rush") +
  theme_bw()+
  ggtitle("Defensive YPP for rush & pass 2026 WEEK 3")

getwd()
write.csv(team_plot_def_data_p5,"team_plot_p4_def_ypp_week3.csv")

################################################################################

con <- dbConnect(
  RPostgres::Postgres(),
  dbname = "tsdb",
  host = "localhost",
  port = 5432,
  user = "jack",
  password = "StCroixRiver"
)

dbExecute(con, "SET search_path TO cfb2026, public;")

dbWriteTable(con, Id(schema = "cfb2026", table = "team_plot_off_data_p5"),
             team_plot_off_data_p5, overwrite = TRUE)

dbWriteTable(con, Id(schema = "cfb2026", table = "team_plot_def_data_p5"),
             team_plot_def_data_p5, overwrite = TRUE)

# Convert to standard data.frame to strip custom package classes
pbp_raw_df <- as.data.frame(pbp_raw)

dbWriteTable(
  conn = con, 
  name = DBI::Id(schema = "cfb2026", table = "pbp_raw_3"),
  value = pbp_raw_df, 
  overwrite = TRUE
)

dbExistsTable(con, DBI::Id(schema = "cfb2026", table = "pbp_raw_3"))

dbDisconnect(con)

