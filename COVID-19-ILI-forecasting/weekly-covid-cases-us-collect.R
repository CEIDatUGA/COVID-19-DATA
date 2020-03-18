library(dplyr)
library(tidyr)
library(MMWRweek)

# reading in csv for now, but the OAUTH code at the end will need to manually updated, roughly weekly
# might be better to just access the data set by automatically pulling from the COVID-19-DATA github repo to local folder and then uploading from there
us_cases <- read.csv("https://raw.githubusercontent.com/CEIDatUGA/COVID-19-DATA/master/UScases_by_state_wikipedia.csv?token=AMRZYPMEVQVPCB3C2CR5XKC6PEZFC")
state_template <- read.csv("~/Documents/UGA/COVID-19-ILI-forecasting-master/templates-and-data/covid19-ili-forecast-state-template.csv")

us_state_code <- read.csv("https://raw.githubusercontent.com/jasonong/List-of-US-States/master/states.csv", stringsAsFactors = F)
us_state_code <- rbind(us_state_code, c("Puerto Rico", "PR"),  c("Virgin Islands", "VI"), c("Guam", "GU"))


format_cases <- function(us_cases, us_state_code, state_template){
  
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
    select(State_Code, Date, state_daily_cases, national_cml_cases = Conf_Cml, national_cml_deaths = Death_Cml, national_cml_rec = Rec_Cml, date_time_accessed) %>%
    # fill in zeros for days with no cases
    mutate_at(c("state_daily_cases", "national_cml_cases", "national_cml_deaths", "national_cml_rec"),~ifelse(is.na(.), 0, .))
  
  # joining with state and territory names, instead of just codes to match state_template
  us_cases3 <- left_join(us_cases2, us_state_code, by = c("State_Code" = "Abbreviation")) %>%
    rename(location = State) %>% 
    select(location, everything()) 
  
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
  us_cases_weekly <- fun_add_weekly_cases(us_cases3)
  
  
  return(us_cases_weekly)
  
}

us_cases_data <- format_cases(us_cases, us_state_code)

us_cases_data_weekly <- us_cases_data %>% 
  select(-Date, -c(state_daily_cases:national_cml_rec)) %>% 
  group_by(location, WeekStart) %>% 
  distinct()

write.csv(us_cases_data_weekly, "~/COVID19-ILI-forecasting/data/us_cases_data_weekly.csv")
