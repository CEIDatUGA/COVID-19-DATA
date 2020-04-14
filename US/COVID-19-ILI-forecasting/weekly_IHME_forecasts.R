library(dplyr)

# collect weekly covid deaths from UW IHME forecasts
# https://ihmecovid19storage.blob.core.windows.net/latest/ihme-covid19.zip

# set working directory to COVID-19-DATA repo
setwd("~/work/COVID-19-DATA")

IHME <- read.csv("US/COVID-19-ILI-forecasting/2020_04_12.02/Hospitalization_all_locs.csv", stringsAsFactors = F)

us_states <- read.csv("US/COVID-19-ILI-forecasting/data/us_cases_data_weekly_states.csv", stringsAsFactors = F) %>% 
  select(location) %>% distinct()

IHME_deaths <- IHME %>% select(location = location_name, date, totdea_mean) %>%
  # combine WA state predictions into one
  mutate(location = case_when(location %in% c("Other Counties, WA", "Life Care Center, Kirkland, WA", "King and Snohomish Counties (excluding Life Care Center), WA") ~ "Washington", 
                                     TRUE ~ location)) %>%
  # designate if locations are states/territory vs. national level
  mutate(location_level = case_when(location == "United States of America" ~ "national",
                                   TRUE ~ "state"),
         date = as.Date(date)) %>% 
  # designate which are from united states
  mutate(country = case_when(location %in% c(us_states$location, "United States of America") ~ "United States",
                             TRUE ~ "international"))



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

