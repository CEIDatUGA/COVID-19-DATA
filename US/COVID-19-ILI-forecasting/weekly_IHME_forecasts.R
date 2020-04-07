library(dplyr)

# collect weekly covid deaths from UW IHME forecasts
# https://www.medrxiv.org/content/10.1101/2020.03.27.20043752v1.full.pdf

# set working directory to COVID-19-DATA repo
setwd("~/work/COVID-19-DATA")

IHME <- read.csv("US/COVID-19-ILI-forecasting/2020_04_01.2/Hospitalization_all_locs.csv", stringsAsFactors = F)

IHME_deaths <- IHME %>% select(location, date, totdea_mean) %>%
  # combine WA state predictions into one
  mutate(location = case_when(location %in% c("Other Counties, WA", "Life Care Center, Kirkland, WA", "King and Snohomish Counties (excluding Life Care Center), WA") ~ "Washington", 
                                     TRUE ~ location)) %>%
  # designate if locations are states/territory vs. naitonal level
  mutate(location_level = case_when(location == "US" ~ "national",
                                   TRUE ~ "state"),
         date = as.Date(date))



# sum daily new cases to get weekly new deaths
fun_add_weekly_cases <- function(x){
  # start of the week = Monday
  tmp <- x %>% mutate(Weekday = weekdays(date))
  tmp <- tmp %>% mutate(WeekStart = case_when(Weekday == "Monday" ~ date - 1,
                                              Weekday == "Tuesday" ~ date - 2,
                                              Weekday == "Wednesday" ~ date - 3, 
                                              Weekday == "Thursday" ~ date - 4,
                                              Weekday == "Friday" ~ date - 5,
                                              Weekday == "Saturday" ~ date - 6,
                                              Weekday == "Sunday" ~ date
  )) %>% select(-Weekday)
  tmp2 <- tmp %>% group_by(WeekStart, location) %>% 
    # sum new daily cases for each week
    mutate(weekly_deaths_mean = sum(totdea_mean)) %>%
    ungroup()
  
  tmp3 <- tmp2 %>% mutate(epiweek = MMWRweek::MMWRweek(WeekStart)$MMWRweek)
  
  tmp4 <- tmp3 %>% select(location_level, location, WeekStart, epiweek, weekly_deaths_mean) %>% distinct()
  return(tmp4)
  
}

weekly_deaths <- fun_add_weekly_cases(IHME_deaths)

write.csv(weekly_deaths, "US/COVID-19-ILI-forecasting/data/IHME_forecasted_deaths.csv")

