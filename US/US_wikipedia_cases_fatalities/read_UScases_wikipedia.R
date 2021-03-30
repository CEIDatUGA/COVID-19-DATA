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
library(USAboundaries)

#----------#
# Functions
#----------#
char_to_num <- function(x,decimalmarker = ".") {
  x <- as.character(x) # ensure factors treated as strings
  
  # check decimal marker (will not catch problems if all numbers are ambiguous)
  lengths <- lengths(regmatches(x, gregexpr(paste0("\\",decimalmarker), x)))
  if(any(lengths>1)) {
    stop("Incorrect decimal marker specified. 
         Use argument 'decimalmarker' to set correctly.")
  }
  
  # remove all characters except the decimal marker and digits
  pattern <- paste0("[^",decimalmarker,"0-9]")
  x <- gsub(pattern, "", x)
  
  # coerce decimalmarker to "." for conversion to numeric
  x <- gsub(paste0("\\",decimalmarker),".",x)
  # conversion to numeric
  x <- as.numeric(x)
  if(anyNA(x)) { warning("NAs introduced by coercion") }
    
  return(x) 
}

read_table_from_web <- function(wiki_pop, table_xpath) {
  cases <- wiki_pop %>%
    html_nodes(xpath=table_xpath) %>%
    html_table(fill=TRUE)
  return(cases)
}

table_cleanup <- function(cases, var) {
  # table of interest is the first element of the list
  cases <- cases[[1]]

  # state column names
  tmp_col_names <- as.character(cases[1,])
  state_columns <- tmp_col_names[as.character(tmp_col_names) %in% USAboundaries::state_codes$state_abbr]

  # Remove extra header rows and summary rows
  rows_to_remove <- which(cases$Date %in% c("Date","Total","Notes","Refs"))
  cases <- cases[-rows_to_remove,]

  # table columns
  if (var == "cases") {
    # columns
    summary_columns <- c("Conf_New", "Conf_Cml", "deaths_New", "deaths_Cml", "Rec_New", "Rec_Cml", "Active")
    col_names <- c("Date", state_columns, "Date2", summary_columns)
    if(ncol(cases) != length(col_names)) {
      stop("Error in column headings for table of cases.")
      }
     # add first recovered case to the new recovery cases column
     # index <- which(as.character(cases$Date) == "Feb 15")
     # cases[index, "Rec_New"] <- as.numeric(cases[index, "Rec_Cml"])
  }
  else if (var == "deaths") {
    summary_columns <- c( "deaths_New", "deaths_Cml")
    col_names <- c("Date", state_columns, "Date2", summary_columns)
    if(ncol(cases) != length(col_names)) {
      stop("Error in column headings for table of deaths.")
    }
  }
  else {
    abort("Table format not given.")
  }
  
  # Assign column names
  names(cases) <- col_names 
  
  # Remove exctra date column
  cases$Date2 <- NULL
  
  # Column data types
  cases$Date <- as.Date(cases$Date, "%d-%b-%y")
  numeric_columns <- which(names(cases) != "Date")
  #cases[,numeric_columns] <- lapply(cases[,numeric_columns], as.numeric) # incorrect
  cases[,numeric_columns] <- lapply(cases[,numeric_columns], char_to_num)
  
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
xpath_cases <- '//*[@id="mw-content-text"]/div[1]/div[2]/table'
xpath_deaths <- '//*[@id="mw-content-text"]/div[1]/div[3]/table'

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

# delete totals row
n <- dim(us_cases_clean)[1]
us_cases_clean <- us_cases_clean[-n,]
n <- dim(us_deaths_clean)[1]
us_deaths_clean <- us_deaths_clean[-n,]

write.csv(us_cases_clean, "US/US_wikipedia_cases_fatalities/UScases_by_state_wikipedia.csv", row.names = FALSE)
write.csv(us_deaths_clean, "US/US_wikipedia_cases_fatalities/USfatalities_by_state_wikipedia.csv", row.names = FALSE)

