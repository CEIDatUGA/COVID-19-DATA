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

cases <- read.csv(url("https://raw.githubusercontent.com/ishaberry/Covid19Canada/master/cases.csv"))
codebook <- read.csv(url("https://raw.githubusercontent.com/ishaberry/Covid19Canada/master/codebook.csv"))
mortality <- read.csv(url("https://raw.githubusercontent.com/ishaberry/Covid19Canada/master/mortality.csv"))
recovered_cumulative <- read.csv(url("https://raw.githubusercontent.com/ishaberry/Covid19Canada/master/recovered_cumulative.csv"))
testing_cumulative <- read.csv(url("https://raw.githubusercontent.com/ishaberry/Covid19Canada/master/testing_cumulative.csv"))

#save in our repo
write.csv(cases, "global/canada_case_data_ishaberry/canada_cases.csv", row.names = F)
write.csv(codebook, "global/canada_case_data_ishaberry/canada_codebook.csv", row.names = F)
write.csv(mortality, "global/canada_case_data_ishaberry/canada_mortality.csv", row.names = F)
write.csv(recovered_cumulative, "global/canada_case_data_ishaberry/canada_recovered_cumulative.csv", 
          row.names = F)
write.csv(testing_cumulative, "global/canada_case_data_ishaberry/canada_testing_cumulative.csv", row.names = F)

