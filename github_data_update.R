#Github update
## MV Evans April 2020

#' This script downloads any data that is stored in other github repos to update the
#' copies kept in this repo. This script is run daily.
#' 
#' Includes:
#' 
#' 1. COVID-19 Case data from Canada (https://github.com/ishaberry/Covid19Canada)
#' 
#' 

#set wd to source file location (head of project dir)
options(stringsAsFactors = F)

#### COVID-19 Case data from Canada

# Cases
cases2020 <- read.csv(url("https://raw.githubusercontent.com/ccodwg/Covid19Canada/master/individual_level/cases_2020.csv"))
cases2021 <- read.csv(url("https://raw.githubusercontent.com/ccodwg/Covid19Canada/master/individual_level/cases_2021.csv"))
cases <- rbind(cases2020, cases2021)

# Mortality
mortality2020 <- read.csv(url("https://raw.githubusercontent.com/ccodwg/Covid19Canada/master/individual_level/mortality_2020.csv"))
mortality2021 <- read.csv(url("https://raw.githubusercontent.com/ccodwg/Covid19Canada/master/individual_level/mortality_2021.csv"))
mortality <- rbind(mortality2020, mortality2021)

codebook <- read.csv(url("https://raw.githubusercontent.com/ccodwg/Covid19Canada/master/other/codebook.csv"))

recovered_cumulative <- read.csv(url("https://raw.githubusercontent.com/ccodwg/Covid19Canada/master/timeseries_prov/recovered_timeseries_prov.csv"))
testing_cumulative <- read.csv(url("https://raw.githubusercontent.com/ccodwg/Covid19Canada/master/timeseries_prov/testing_timeseries_prov.csv"))

#change date to YYYY-MM-DD
cases$date_report <- as.Date(cases$date_report, format = "%d-%m-%Y")
mortality$date_death_report <- as.Date(mortality$date_death_report, format = "%d-%m-%Y")
recovered_cumulative$date_recovered <- as.Date(recovered_cumulative$date_recovered, format = "%d-%m-%Y")
testing_cumulative$date_testing <- as.Date(testing_cumulative$date_testing, format = "%d-%m-%Y")

#save in our repo
write.csv(cases, "global/canada_case_data_ishaberry/canada_cases.csv", row.names = F)
write.csv(codebook, "global/canada_case_data_ishaberry/canada_codebook.csv", row.names = F)
write.csv(mortality, "global/canada_case_data_ishaberry/canada_mortality.csv", row.names = F)
write.csv(recovered_cumulative, "global/canada_case_data_ishaberry/canada_recovered_cumulative.csv", 
          row.names = F)
write.csv(testing_cumulative, "global/canada_case_data_ishaberry/canada_testing_cumulative.csv", row.names = F)

