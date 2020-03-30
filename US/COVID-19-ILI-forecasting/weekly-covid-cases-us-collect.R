library(dplyr)
library(tidyr)
library(MMWRweek)

# set working directory to COVID-19-DATA repo
setwd("~/work/COVID-19-DATA")

# reading in csv for now, but the OAUTH code at the end will need to manually updated, roughly weekly
# might be better to just access the data set by automatically pulling from the COVID-19-DATA github repo to local folder and then uploading from there
us_cases <- read.csv("US/US_wikipedia_cases_fatalities/UScases_by_state_wikipedia.csv")

us_state_code <- read.csv("https://raw.githubusercontent.com/jasonong/List-of-US-States/master/states.csv", stringsAsFactors = F)
us_state_code <- rbind(us_state_code, c("Puerto Rico", "PR"),  c("Virgin Islands", "VI"), c("Guam", "GU"))

# county level data from https://usafacts.org/visualizations/coronavirus-covid-19-spread-map/
# need to get counts for NYC, forecasted separately from NY 
# download csv from html, not sure if this link is persistent
county_cases <- read.csv("https://static.usafacts.org/public/data/covid-19/covid_confirmed_usafacts.csv", stringsAsFactors = F)


format_cases <- function(us_cases = us_cases, us_state_code = us_state_code, county_cases = county_cases){
  
  # getting rid of row of country-level counts
  us_cases2 <- us_cases %>% filter(Date != "Total") %>% 
    # converting to long format
    tidyr::gather(key = "State", value = "state_daily_cases", -c(Date, Conf_New:time_last_update)) %>% 
    # convert to date format, automatically fills in year as 2020
    mutate(Date = as.Date(Date, format = "%b %d")) %>% 
    # add column of date and time wikipedia page was scraped, useful for backfill
    mutate(date_time_accessed = max(as.POSIXct(time_last_update), na.rm = T)) %>% 
    rename(State_Code = State) %>%
    # remove unwanted columns
    select(State_Code, Date, state_daily_cases, national_cml_cases = Conf_Cml, national_cml_deaths = deaths_Cml, national_cml_rec = Rec_Cml, date_time_accessed) %>%
    # fill in zeros for days with no cases
    mutate_at(c("state_daily_cases", "national_cml_cases", "national_cml_deaths", "national_cml_rec"),~ifelse(is.na(.), 0, .))
  
  # joining with state and territory names, instead of just codes to match state_template
  us_cases3 <- left_join(us_cases2, us_state_code, by = c("State_Code" = "Abbreviation")) %>%
    rename(location = State) %>% 
    select(location, everything()) 
  
  nyc_cases2 <- county_cases %>% 
    # include data from each of the counties that make up the 5 boroughs of NYC
    filter(County.Name %in% c("Queens County", "Kings County", "New York County", "Bronx County", "Richmond County") & State == "NY") %>% group_by(State) %>%
    summarise_if(is.numeric, ~sum(., na.rm = T)) %>% mutate(County.Name = "New York City") %>% 
    gather(key = "Date", value = "NYC_cumulative", -c(countyFIPS, stateFIPS, State, County.Name)) %>% 
    # convert Date to correct date format
    mutate_at("Date",  ~ as.Date(gsub(pattern = "X", replace = "", .), format = "%m.%d.%Y")) %>%
    mutate(date_time_accessed = Sys.time()) %>%
    mutate(state_daily_cases = NYC_cumulative - lag(NYC_cumulative, default = 0)) %>%
    select(location = County.Name, State_Code = State, Date, state_daily_cases, date_time_accessed) 
  
  # add rows for location = New York City
  us_cases4 <- full_join(us_cases3, nyc_cases2)
  
  # sum daily new cases to get weekly new cases
  fun_add_weekly_cases <- function(x){
    # start of the week = Monday
    tmp <- x %>% mutate(Weekday = weekdays(Date))
    tmp <- tmp %>% mutate(WeekStart = case_when(Weekday == "Monday" ~ Date - 1,
                                                Weekday == "Tuesday" ~ Date - 2,
                                                Weekday == "Wednesday" ~ Date - 3, 
                                                Weekday == "Thursday" ~ Date - 4,
                                                Weekday == "Friday" ~ Date - 5,
                                                Weekday == "Saturday" ~ Date - 6,
                                                Weekday == "Sunday" ~ Date
    )) %>% select(-Weekday)
    tmp2 <- tmp %>% group_by(WeekStart, location) %>% 
      # sum new daily cases for each week
      mutate(state_weekly_cases = sum(state_daily_cases)) %>%
      # get maximum of cumulative cases for each week
      mutate(national_weekly_cases = max(national_cml_cases),
             national_weekly_deaths = max(national_cml_deaths),
             national_weekly_rec = max(national_cml_rec)) %>%
      ungroup()
    
    tmp3 <- tmp2 %>% mutate(epiweek = MMWRweek::MMWRweek(WeekStart)$MMWRweek)
    return(tmp3)
    
  }
  us_cases_weekly <- fun_add_weekly_cases(us_cases4)
  
  
  return(us_cases_weekly)
  
}

us_cases_data <- format_cases(us_cases, us_state_code, county_cases)

us_cases_data_weekly <- us_cases_data %>% 
  select(-Date, -c(state_daily_cases:national_cml_rec)) %>% 
  group_by(location, WeekStart) %>% 
  distinct()

# subtract NYC cases from NY state cases
sep_nyc_cases <- function(us_cases_data_weekly = us_cases_data_weekly) {
  ny_cases <- us_cases_data_weekly %>% 
    filter(location == "New York") 
  nyc_cases <- us_cases_data_weekly %>% 
    filter(location == "New York City") %>% 
    rename(nyc_weekly_cases = state_weekly_cases) %>% 
    select(WeekStart, nyc_weekly_cases, NYC = location)
  tmp <- left_join(ny_cases, nyc_cases, by = "WeekStart") %>% 
    mutate(state_weekly_cases = state_weekly_cases - nyc_weekly_cases) %>%
    select(-nyc_weekly_cases, -NYC)
  
  tmp2 <- us_cases_data_weekly %>% filter(location != "New York")
  tmp3 <- rbind(tmp, tmp2) %>% arrange(location, WeekStart)
  return(tmp3) 
  }

us_cases_data_weekly2 <- sep_nyc_cases(us_cases_data_weekly) 

# weekly data set for states, territories, and NYC
us_cases_data_weekly_states <- us_cases_data_weekly2 %>%
  select(location, State_Code, WeekStart, epiweek, state_weekly_cases, date_time_accessed)

# time series of national level data 
us_cases_data_weekly_national <- us_cases_data_weekly2 %>% ungroup() %>%
  select(WeekStart, epiweek, national_weekly_cases, national_weekly_deaths, national_weekly_rec, date_time_accessed) %>%
  distinct()

write.csv(us_cases_data_weekly_states, "US/COVID-19-ILI-forecasting/data/us_cases_data_weekly_states.csv")
write.csv(us_cases_data_weekly_national, "US/COVID-19-ILI-forecasting/data/us_cases_data_weekly_national.csv")
