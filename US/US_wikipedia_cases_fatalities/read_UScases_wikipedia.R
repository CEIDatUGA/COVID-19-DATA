# Reads US COVID-19 cases and deaths from wikipedia page "2020_coronavirus_pandemic_in_the_United_States" 
# Currently, deaths are extracted from an older version of the same page: 2020-03-16 12:39:08 

#-------------------------------------------------------------------------------------------#
# README BEFORE RUNNING: the wiki table's 'xpath' might need to be updated due to changes in the 
# wiki page; instructions below on how to copy most current XPath
# If the wiki table format changes, the function 'table_cleanup' will need to be adjusted
#-------------------------------------------------------------------------------------------#
# Instructions to copy most current table XPath:
# 1. Go to url below
# 2. Scroll down to table 'Non-repatriated COVID-19 cases in the US by state"
# 3. With cursor on table, pres the mouse secondary button
# 4. Click 'Inspect', a window will open on the right side of the screen
# 5. On the html code, scroll up and click on the row with "<table class="wikitable....>"
# 6. Pres the mouse secondary button
# 7. Select 'Copy'
# 8. Select 'Copy XPath'
# 9. Update Xpath variable below

#---------#
# Packages
#---------#
#install.packages("rvest")
#install.packages("xml2")
library(rvest)
library(xml2)

#----------#
# Functions
#----------#
read_table_from_web <- function(wiki_pop, table_xpath) {
  cases <- wiki_pop %>%
    html_nodes(xpath=table_xpath) %>%
    html_table(fill=TRUE)
  return(cases)
}

table_cleanup <- function(cases, var) {
  # table of interest is the first element of the list
  cases <- cases[[1]]
  # keep the first column 'Date'
  date <- as.factor(cases[,1])
  # delete two columns with name 'Date'
  cases <- subset(cases, select = -c(Date))
  cases <- subset(cases, select = -c(Date))
  # add column 'Date' back to data frame
  cases <- cbind(date, cases)
  
  # updating column names
  ncols <- dim(cases)[2]
  col_names <- as.character(cases[1,])
  col_names <- col_names[!as.character(col_names) %in% "West"]

  if (var == "cases") {
    col_names[1] <- "Date"
    col_names[c((ncols-6):ncols)] <- c("VI", "Conf_New", "Conf_Cml", "deaths_New", "deaths_Cml", "Rec_New", "Rec_Cml")
     names(cases) <- col_names 
     
     # add first recovered case to the new recovery cases column
     index <- which(as.character(cases$Date) == "Feb 15")
     cases[index, "Rec_New"] <- as.numeric(cases[index, "Rec_Cml"])
  }
  else if (var == "deaths") {
    col_names[1] <- "Date"
    col_names[c((ncols-2):ncols)] <- c("VI", "deaths_New", "deaths_Cml")
    names(cases) <- col_names 
  }
  else {
    abort("table format not given")
  }
  
  # eliminating no interest rows 
  cases <- cases[-1,] 
  nrows <- dim(cases)[1]
  cases <- cases[-c((nrows-3):nrows),]
  
  return(cases)
}

time_last_update <- function(cases) {
  cases$time_last_update[dim(cases)[1]] <- as.character(Sys.time())
  cases$time_last_update[dim(cases)[1]-1] <- as.character(Sys.time())
  return(cases) 
}

#-----------#
# Main code
#-----------#

# Update xpath here
xpath_cases <- '//*[@id="mw-content-text"]/div/div[2]/table'
xpath_deaths <- '//*[@id="mw-content-text"]/div/div[3]/table'

# Read webpage
url <- "https://en.wikipedia.org/wiki/Template:2019–20_coronavirus_pandemic_data/United_States_medical_cases"
wiki_pop <- read_html(url)

# extract tables from webpage 
us_cases <- read_table_from_web(wiki_pop, xpath_cases)
us_deaths <- read_table_from_web(wiki_pop, xpath_deaths)

# table cleanup & column names reformat 
us_cases_clean <- table_cleanup(us_cases, "cases")
us_deaths_clean <- table_cleanup(us_deaths, "deaths")

us_cases_clean <- time_last_update(us_cases_clean)
us_deaths_clean <- time_last_update(us_deaths_clean)

write.csv(us_cases_clean, "UScases_by_state_wikipedia.csv", row.names = FALSE)
write.csv(us_deaths_clean, "USfatalities_by_state_wikipedia.csv", row.names = FALSE)

