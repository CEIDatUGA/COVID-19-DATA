## GA DPH file reader and organizer
## MV Evans, June 2020

#' This script will download COVID data from the GA DPH website (https://dph.georgia.gov/covid-19-daily-status-report) 
#' and organize it to match our workflow and append to files.
#' 

options(stringsAsFactors = F)

current.time <- as.character(Sys.time())
today.date <- as.character(Sys.Date())

#download zip file
new.dir <- paste0("georgia/ga_GDPH_daily_status_report/raw-data/", today.date)
dir.create(new.dir, recursive = T)
download.file(url = "https://ga-covid19.ondemand.sas.com/docs/ga_covid_data.zip", 
              destfile = paste0(new.dir, "/ga_covid_data.zip"))

#extract zip file
unzip(paste0(new.dir, "/ga_covid_data.zip"), exdir = new.dir)

##### Case Data ####
new.cases <- read.csv(paste0(new.dir, "/countycases.csv")) 
new.cases$case_rate <- NULL

colnames(new.cases) <- c("County", "Cases", "Fatalities", "Hospitalizations")
new.cases$Latest_Status_Report <- current.time

#save
write.csv(new.cases, "georgia/ga_GDPH_daily_status_report/GA_county_cases_fatalities_GDPH.csv", row.names = F)

#### Line List ####
new.linelist <- read.csv(paste0(new.dir, "/deaths.csv"))
new.linelist$Latest_Status_Report <- current.time

write.csv(new.linelist, "georgia/ga_GDPH_daily_status_report/GA_fatalities_demography_GDPH.csv", row.names = F)

#### Race & Ethnicity ####
new.race <- read.csv(paste0(new.dir, "/demographics.csv"))
new.race$Latest_Status_Report <- current.time

write.csv(new.race, "georgia/ga_GDPH_daily_status_report/GA_cases_race_ethnicity_GDPH.csv", row.names = F)

#### Daily Status Report ####
old.report <- read.csv("georgia/ga_GDPH_daily_status_report/GA_daily_status_report_GDPH.csv")

last.tail <- tail(old.report,1)


# update with new things
new.row <- data.frame(X = last.tail$X + 1,
                      date = today.date,
                      time_reported = substr(current.time, 12, 20),
                      cases_cumulative = sum(new.cases$Cases),
                      fatalities_cumulative = sum(new.cases$Fatalities),
                      tests_cumulative = NA,
                      hospitalizations_cumulative = sum(new.cases$Hospitalizations),
                      new_cases = sum(new.cases$Cases)-last.tail$cases_cumulative,
                      new_fatalities = sum(new.cases$Fatalities) - last.tail$fatalities_cumulative,
                      new_tests = NA,
                      new_hospitalizations = sum(new.cases$Hospitalizations) - last.tail$hospitalizations_cumulative,
                      source_cases = "https://ga-covid19.ondemand.sas.com/docs/ga_covid_data.zip",
                      source_fatalities = "https://ga-covid19.ondemand.sas.com/docs/ga_covid_data.zip",
                      source_tests = "https://ga-covid19.ondemand.sas.com/docs/ga_covid_data.zip",
                      source_hospitalizations = "https://ga-covid19.ondemand.sas.com/docs/ga_covid_data.zip")

if(new.row$date != last.tail$date){
  new.report <- rbind(old.report, new.row)
  #save
  write.csv(new.report, "georgia/ga_GDPH_daily_status_report/GA_daily_status_report_GDPH.csv", row.names = F)
}