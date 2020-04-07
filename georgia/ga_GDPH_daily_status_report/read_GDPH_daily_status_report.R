# extract data from Georgia Department of Public Health

library(rvest)
library(xml2)
library(stringr)
library(lubridate)

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
#url <- "https://dph.georgia.gov/covid-19-daily-status-report"
#xpath_cases <- '//*[@id="main-content"]/div/div[3]/div[1]/div/main/div[2]/table[1]'
#xpath_tests <- '//*[@id="main-content"]/div/div[3]/div[1]/div/main/div[2]/table[2]'

url <-  "https://d20s4vd27d0hk0.cloudfront.net/?initialWidth=578&childId=covid19dashdph&parentTitle=COVID-19%20Daily%20Status%20Report%20%7C%20Georgia%20Department%20of%20Public%20Health&parentUrl=https%3A%2F%2Fdph.georgia.gov%2Fcovid-19-daily-status-report%23main-content"
xpath_cases <- '//*[@id="summary"]/table[1]'
xpath_counties <- '//*[@id="summary"]/table[2]'
xpath_tests <- '//*[@id="testing"]/table'
xpath_deaths <- '//*[@id="deaths"]/table' 
  
webtext <- read_html(url)

table_cases <- read_table_from_web(webtext, xpath_cases)
table_tests <- read_table_from_web(webtext, xpath_tests)
table_counties <- read_table_from_web(webtext, xpath_counties)
table_demography <- read_table_from_web(webtext, xpath_deaths)

date_reported <- str_extract(as.character(webtext), "[0-9]+\\/[0-9]+\\/[0-9]+ [0-9]+\\:[0-9]+\\:[0-9]+")
aux <- strsplit(date_reported, " ")
day <- aux[[1]][1]
date_reported <- format(parse_date_time(day,"mdy"), format="%m/%d/%y")
time_reported <- aux[[1]][2]
#time_reported <- gsub("[\\(|\\)]", "",str_extract(as.character(webtext), "\\([0-9]+\\:[0-9]+ [a|p]m\\)"))

table_cases <- table_cases[[1]]
table_tests <- table_tests[[1]]
table_tests <- table_tests[-1,]
df  <- data.frame(date = as.character(date_reported),
                time_reported = as.character(time_reported),
                cases_cumulative = as.numeric(str_extract(table_cases[2,2], "[0-9]+")), 
                fatalities_cumulative = as.numeric(str_extract(table_cases[3,2], "[0-9]+")), 
                hospitalized_cumulative = as.numeric(str_extract(table_cases[4,2], "[0-9]+")),
                tests_cumulative = sum(as.numeric(table_tests$X3)),
                new_cases = NA,
                new_fatalities = NA,
                new_tests = NA,
                source_cases = as.character(url),
                source_fatalities = as.character(url),
                source_tests = as.character(url)
                 )

# Read existent status report table
table <- read.csv("GA_daily_status_report_GDPH.csv", header = TRUE, stringsAsFactors = FALSE, na.strings = "")
table <- table[,-1]
table$date <- unlist(lapply(table$date, function(x) format(as.Date(parse_date_time(x,"mdy")), format = "%m/%d/%y")))
nrows <- dim(table)[1]              

# if there is already an entry for that day, it will replace that row by the latest page update
day_last_row <- format(as.Date(parse_date_time(table$date[nrows],"mdy")), format = "%m/%d/%y")
if(identical(day_last_row, as.character(date_reported))){
    cols <- c(1, 2, 6, 7, 8)   
    df[,cols] <- apply(df[,cols], 2, function(x) (as.character(x)))
    table[nrows,] <- df
} else{
   table <- rbind(table, df) # if not, it will add the report for that day
}

table[, c(3:5)] <- table[, c(3:5)] %>%
  mutate_if(is.character, as.numeric, na.rm = TRUE) 
  
table <- table %>% 
  mutate(new_cases = cases_cumulative - lag(cases_cumulative, default = first(cases_cumulative))) %>%
  mutate(new_fatalities = fatalities_cumulative - lag(fatalities_cumulative, default = first(fatalities_cumulative))) %>%
  mutate(new_tests = tests_cumulative - lag(tests_cumulative, default = first(tests_cumulative))) 

write.csv(table, "GA_daily_status_report_GDPH.csv")




