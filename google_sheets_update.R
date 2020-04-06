## Master gsheets downloader
# MV Evans, March 27 2020

#' This script downloads google sheets that the Data Coordinator is maintaining. This is
#' primarily sheets that are uploaded at least weekly. Currently, this script is run (and 
#' the associated datasets are updated) on Monday and Thursday. If you need it run more
#' frequently contact the Data Coordinator or run the script in your own fork.
#' 

#' Datasets included in this script
#' 1. COVID-19 Global case data: Exposure locations
#' 2. Global First Cases at ADM1 level
#' 3. China Travel Advisories
#' 4. International Travel Advisories
#' 5. Epidemiological characteristic of 2019-nCoV and other zoonotic pathogens

options(stringsAsFactors = F)

#wd should be set to source file location
library(googlesheets4)
library(dplyr)

##### exposure locations ####
df <- read_sheet("https://docs.google.com/spreadsheets/d/150Kc-hjh9uPTNigEL6L0E8i0KTF77utMmSu1AdSRAgY/edit#gid=0",
                 sheet = 1)
str(df)
head(df)

metadata <- read_sheet("https://docs.google.com/spreadsheets/d/150Kc-hjh9uPTNigEL6L0E8i0KTF77utMmSu1AdSRAgY/edit#gid=0",
                       sheet = 2)

knitr::kable(metadata)

write.csv(df, "global/global_exposure_locations.csv", row.names = F)

#### Global First Cases at ADM1 Level ####
df <- read_sheet("https://docs.google.com/spreadsheets/d/1eA5YOdaZvEhDcse4W6qq7Q_D8AciZx_1ZSgORxUppGo/edit#gid=0",
                 sheet = 1)
str(df)
head(df)

#fix list-columns [problem is NULL]
listcol_to_date <- function(listcol){
  listcol[sapply(listcol, is.null)] <- NA
  date <- as.character(unlist(listcol))
  return(date)
}

df$confirmation_date <- listcol_to_date(df$confirmation_date)
df$accessed_date1 <- listcol_to_date(df$accessed_date1)


metadata <- read_sheet("https://docs.google.com/spreadsheets/d/1eA5YOdaZvEhDcse4W6qq7Q_D8AciZx_1ZSgORxUppGo/edit#gid=0",
                       sheet = 3)

knitr::kable(metadata)

write.csv(df, "global/global_first_case.csv", row.names = F)

#### China Travel Advisories ####

df <- read_sheet("https://docs.google.com/spreadsheets/d/1cYqkGOy4ZjHSIeRqyfyi7UvYnG6-UlBAJWD8GMFZA7I/edit#gid=1169808441",
                 sheet = 1)

str(df)
tail(df)

write.csv(df, "china/China_TA.csv", row.names = F)

#### Global Travel Advisories ####

df <- read_sheet("https://docs.google.com/spreadsheets/d/1cYqkGOy4ZjHSIeRqyfyi7UvYnG6-UlBAJWD8GMFZA7I/edit#gid=1169808441",
                 sheet = 3)

str(df)
tail(df)

write.csv(df, "global/International_TA.csv", row.names = F)


#### Epidemiological characteristic of 2019-nCoV and other zoonotic pathogens ####

df <- read_sheet("https://docs.google.com/spreadsheets/d/18rhrw1d9uDtm8ffLaFmFXjcY8zFCcYqesEoso2EICE0/edit#gid=0",
                 sheet = 1)

str(df)
tail(df)

write.csv(df, "nongeographic/Epi_characteristics.csv", row.names = F)


