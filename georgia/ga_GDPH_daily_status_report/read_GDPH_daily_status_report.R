# extract data from Georgia Department of Public Health

library(rvest)
library(xml2)
library(stringr)
library(lubridate)
library(dplyr)

#----------#
# Function
#----------#
read_table_from_web <- function(wiki_pop, table_xpath) {
  cases <- wiki_pop %>%
    html_nodes(xpath=table_xpath) %>%
    html_table(fill=TRUE)
    cases <- cases[[1]]
  return(cases)
}

# Read webpage
url <-  "https://d20s4vd27d0hk0.cloudfront.net/?initialWidth=578&childId=covid19dashdph&parentTitle=COVID-19%20Daily%20Status%20Report%20%7C%20Georgia%20Department%20of%20Public%20Health&parentUrl=https%3A%2F%2Fdph.georgia.gov%2Fcovid-19-daily-status-report%23main-content"
xpath_cases <- '//*[@id="summary"]/table[1]'
xpath_counties <- '//*[@id="summary"]/table[2]'
xpath_tests <- '//*[@id="testing"]/table'
xpath_deaths <- '//*[@id="deaths"]/table' 
xpath_race <- '//*[@id="race2"]/table'
  
webtext <- read_html(url)

table_cases <- read_table_from_web(webtext, xpath_cases)
table_tests <- read_table_from_web(webtext, xpath_tests)
table_counties <- read_table_from_web(webtext, xpath_counties)
table_demography <- read_table_from_web(webtext, xpath_deaths)
table_race <- read_table_from_web(webtext, xpath_race)

date_reported <- str_extract(as.character(webtext), "[0-9]+\\/[0-9]+\\/[0-9]+ [0-9]+\\:[0-9]+\\:[0-9]+")
aux <- strsplit(date_reported, " ")
day <- aux[[1]][1]
day_reported <- aux[[1]][1]
time_reported <- aux[[1]][2]

df  <- data.frame(date = day_reported,
                time_reported = time_reported,
                cases_cumulative = as.numeric(str_extract(table_cases[2,2], "[0-9]+")), 
                fatalities_cumulative = as.numeric(str_extract(table_cases[4,2], "[0-9]+")), 
                tests_cumulative = as.numeric(table_tests$X3[2])+as.numeric(table_tests$X3[3]),
                hospitalizations_cumulative = as.numeric(str_extract(table_cases[3,2], "[0-9]+")),
                new_cases = NA,
                new_fatalities = NA,
                new_tests = NA,
                new_hospitalizations = NA,
                source_cases = as.character(url),
                source_fatalities = as.character(url),
                source_tests = as.character(url),
                source_hospitalizations = as.character(url)
                 )

# Read existent status report table
table <- read.csv("GA_daily_status_report_GDPH.csv", header = TRUE, stringsAsFactors = FALSE, na.strings = "")
# remove first column
table <- table[,-1]

table$date <- unlist(lapply(table$date, function(x) format(as.Date(parse_date_time(x,"mdy")), format = "%m/%d/%y")))
nrows <- dim(table)[1]              

# if there is already an entry for that day, it will replace that row by the latest page update
day_last_row <- format(as.Date(parse_date_time(table$date[nrows],"mdy")), format = "%m/%d/%Y")
if(identical(day_last_row, as.character(day_reported))){
    cols <- c("date", "time_reported", "source_cases", "source_fatalities", "source_tests", "source_hospitalizations")   
    df[,cols] <- apply(df[,cols], 2, function(x) (as.character(x)))
    table[nrows,] <- df
} else{
   table <- rbind(table, df) # if not, it will add the report for that day
}

# convert number of cases/fatalities/tests/hospitalizations to numeric class
num_cols <- c("cases_cumulative", "fatalities_cumulative", "tests_cumulative", "hospitalizations_cumulative", "new_cases", "new_fatalities", "new_tests", "new_hospitalizations")
table[, num_cols] <- table[, num_cols] %>%
 mutate_if(is.character, as.numeric, na.rm = TRUE) 

table <- table %>%
  mutate(source_cases = as.character(source_cases), 
         source_fatalities = as.character(source_fatalities), 
         source_tests = as.character(source_tests),
         source_hospitalizations = as.character(source_hospitalizations),
         new_cases = cases_cumulative - lag(cases_cumulative, default = first(cases_cumulative)),
         new_fatalities = fatalities_cumulative - lag(fatalities_cumulative, default = first(fatalities_cumulative)),
         new_tests = tests_cumulative - lag(tests_cumulative, default = first(tests_cumulative)),
         new_hospitalizations = hospitalizations_cumulative - lag(hospitalizations_cumulative, default = first(hospitalizations_cumulative))) 
        
write.csv(table, "GA_daily_status_report_GDPH.csv")

#----------#
# Counties
#----------#
table_counties <- table_counties[-1, ]
table_counties$Latest_Status_Report <- NA
names(table_counties) <- c("County", "Cases", "Fatalities", "Latest_Status_Report")
table_counties <- table_counties[-(dim(table_counties)[1]),]
table_counties$Latest_Status_Report <- date_reported
write.csv(table_counties, "GA_county_cases_fatalities_GDPH.csv")

#-----------------------#
# Fatalities Demography
#-----------------------#
table_demography <- table_demography[-1, ]
names(table_demography) <- c("Age",	"Gender",	"County",	"Underlying")
table_demography$Latest_Status_Report <- date_reported
write.csv(table_demography, "GA_fatalities_demography_GDPH.csv")

#------#
# Race
#------#
names <- table_race[1,]
table_race <- table_race[-1, ]
names(table_race) <- names
table_race$Latest_Status_Report <- date_reported
write.csv(table_race, "GA_cases_race_ethnicity_GDPH.csv")

