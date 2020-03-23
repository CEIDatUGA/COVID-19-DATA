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
url <- "https://dph.georgia.gov/covid-19-daily-status-report"
xpath_cases <- '//*[@id="main-content"]/div/div[3]/div[1]/div/main/div[2]/table[1]'
xpath_tests <- '//*[@id="main-content"]/div/div[3]/div[1]/div/main/div[2]/table[2]'

webtext <- read_html(url)
table_cases <- read_table_from_web(webtext, xpath_cases)
table_tests <- read_table_from_web(webtext, xpath_tests)
date_reported <- str_extract(as.character(webtext), "[0-9]+\\/[0-9]+\\/[0-9]+")
date_reported <- format(parse_date_time(date_reported,"mdy"), format="%m/%d/%y")
time_reported <- gsub("[\\(|\\)]", "",str_extract(as.character(webtext), "\\([0-9]+\\:[0-9]+ [a|p]m\\)"))

df  <- data.frame(date = as.character(date_reported),
                time_reported = as.character(time_reported),
                 cases_cumulative = as.numeric(str_extract(table_cases[1,2], "[0-9]+")), 
                 fatalities_cumulative = as.numeric(str_extract(table_cases[2,2], "[0-9]+")), 
                 tests_cumulative = sum(table_tests$'Total Tests'),
                 source_cases = as.character(url),
                 source_fatalities = as.character(url),
                 source_tests = as.character(url)
                 )

# Read existent status report table
table <- read.csv("../GA_daily_status_report_GDPH.csv", header = TRUE, stringsAsFactors = FALSE, na.strings = "")
table <- table[,-1]
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

write.csv(table, "../GA_daily_status_report_GDPH.csv")




