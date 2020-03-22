# extract data from Georgia Department of Public Health

library(rvest)
library(xml2)
library(stringr)
library(lubridate)


#----------#
# Functions
#----------#
read_table_from_web <- function(wiki_pop, table_xpath) {
  cases <- wiki_pop %>%
    html_nodes(xpath=table_xpath) %>%
    html_table(fill=TRUE)
    cases <- cases[[1]]
  return(cases)
}

# Read webpage
url <- "https://dph.georgia.gov/covid-19-daily-status-report"
xpath_cases <- '//*[@id="main-content"]/div/div[3]/div[1]/div/main/div[2]/table[1]'
xpath_tests <- '//*[@id="main-content"]/div/div[3]/div[1]/div/main/div[2]/table[2]'

webtext <- read_html(url)
table_cases <- read_table_from_web(webtext, xpath_cases)
table_tests <- read_table_from_web(webtext, xpath_tests)
date_reported <- str_extract(as.character(webtext), "[0-9]+\\/[0-9]+\\/[0-9]+")
time_reported <- gsub("[\\(|\\)]", "",str_extract(as.character(webtext), "\\([0-9]+\\:[0-9]+ [a|p]m\\)"))
df <- data.frame(date = as.factor(as.Date(parse_date_time(date_reported,"mdy"))),
#df  <- data.frame(date = as.factor(date_reported),
                time_reported = as.factor(time_reported),
                 cases_cumulative = as.numeric(str_extract(table_cases[1,2], "[0-9]+")), 
                 fatalities_cumulative = as.numeric(str_extract(table_cases[2,2], "[0-9]+")), 
                 tests_cumulative = sum(table_tests$'Total Tests'),
                 source_cases = url,
                 source_fatalities = url,
                 source_tests = url
                 )
                
# Read existent status report table
table <- read.csv("../GA_daily_status_report_GDPH.csv", header = TRUE, stringsAsFactors = FALSE, na.strings = "")
table <- table[,-1]
nrows <- dim(table)[1]

# if there is already an entry for that day, it will replace it by the latest update
day <- as.Date(parse_date_time(table$date[nrows],"mdy"))
ifelse(identical(day, today()), 
       table[nrows,] <- df,
       table <- rbind(table, df) # if not, it will add the report for that day
       )

write.csv(table, "../GA_daily_status_report_GDPH.csv")




