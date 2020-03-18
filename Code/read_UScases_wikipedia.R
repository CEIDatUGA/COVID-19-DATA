# Reads US COVID-19 cases and fatalities from wikipedia page "2020_coronavirus_pandemic_in_the_United_States" 
# Currently, fatalities are extracted from an older version of the same page: 2020-03-16 12:39:08 

#-------------------------------------------------------------------------------------------#
# README BEFORE RUNNING: the wiki table's 'xpath' might need to be updated due to changes in the 
# wiki page; instructions below on how to copy most current XPath
# If the wiki table format changes, the function 'table_cleanup' will need to be adjusted
#-------------------------------------------------------------------------------------------#
# Instructions to copy most current table XPath:
# 1. Go to url below
# 2. Scroll down to table 'Non-repatriated COVID-19 cases in the US by state"
# 3. With cursor on table, press the mouse secondary button
# 4. Click 'Inspect', a window will open on the right side of the screen
# 5. On the html code, scroll up and click on the row with "<table class="wikitable....>"
# 6. Press the mouse secondary button
# 7. Select 'Copy'
# 8. Select 'Copy XPath'
# 9. Paste it as argument on function "read_table_from_web"

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
  # updating column names
  ncols <- dim(cases)[2]
  col_names <- cases[1,]

  if (var == "cases") {
    col_names[c((ncols-5):ncols)] <- c("Conf_New", "Conf_Cml", "Death_New", "Death_Cml", "Rec_New", "Rec_Cml")
    names(cases) <- col_names 
  }
  else if (var == "deaths") {
    col_names[c((ncols-1):ncols)] <- c("Death_New", "Death_Cml")
    names(cases) <- col_names 
  }
  else {
    abort("table format not given")
  }
  
  # eliminating rows with no interest
  cases <- cases[-1,] 
  nrows <- dim(cases)[1]
  cases <- cases[-c((nrows-3):nrows),]
  return(cases)
}


time_last_update <- function(cases, var) {
  if (var == 0){
  cases$time_last_update[dim(cases)[1]] <- as.character(Sys.time())
  cases$time_last_update[dim(cases)[1]-1] <- as.character(Sys.time())
  } else {
    cases$time_last_update[dim(cases)[1]] <- as.character("2020-03-16 12:39:08")
    cases$time_last_update[dim(cases)[1]-1] <- as.character("2020-03-16 12:39:08")
  }
  return(cases) 
}

#-----------#
# Main code
#-----------#

# Update xpath here
xpath_cases <- '//*[@id="mw-content-text"]/div/div[20]/table/tbody/tr[2]/td/table'
xpath_deaths <- '//*[@id="mw-content-text"]/div/div[28]/table/tbody/tr[2]/td/table[2]'

# Read webpage
url <- "https://en.wikipedia.org/wiki/2020_coronavirus_pandemic_in_the_United_States#covid19-container"
url_past <- "https://web.archive.org/web/20200316123908/https://en.wikipedia.org/wiki/2020_coronavirus_pandemic_in_the_United_States"

wiki_pop <- read_html(url)
wiki_past <- read_html(url_past)

# extract tables from webpage 
us_cases <- read_table_from_web(wiki_pop, xpath_cases)
us_deaths <- read_table_from_web(wiki_past, xpath_deaths)

# table cleanup & column names reformat 
# NOTE: if table format in wikipedia changes, this function will need to be updated
us_cases_clean <- table_cleanup(us_cases, "cases")
us_deaths_clean <- table_cleanup(us_deaths, "deaths")


write.csv(us_cases_clean, "../UScases_by_state_wikipedia.csv", row.names = FALSE)
write.csv(us_cases_clean, "../USdeaths_by_state_wikipedia.csv", row.names = FALSE)

