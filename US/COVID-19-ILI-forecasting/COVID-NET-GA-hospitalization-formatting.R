# formats Georgia hospitalization  data from COVID-NET
# https://gis.cdc.gov/grasp/COVIDNet/COVID19_3.html

library(dplyr)

# load data 
ga_hosp <- read.csv("~/work/COVID-19-DATA/US/COVID-19-ILI-forecasting/data/COVID-19Surveillance_EIP_Georgia_Data-2.csv",
         skip = 2, na.strings = c("", "null"))

# get accessed_date from csv metadata
ga_hosp_date <- read.csv("~/work/COVID-19-DATA/US/COVID-19-ILI-forecasting/data/COVID-19Surveillance_EIP_Georgia_Data-2.csv",
                        na.strings = c("", "null"), nrows = 1, stringsAsFactors = F, header = F)
ga_hosp_date <- sub(".*downloaded on ", "", ga_hosp_date)
ga_hosp_date <- gsub("\\)", "", ga_hosp_date)
ga_hosp_date <- as.Date(ga_hosp_date, "%b-%d-%Y")

# add accessed date as a column
ga_hosp_out <- ga_hosp %>% filter(CATCHMENT == "Georgia") %>% mutate(DATE.ACCESSED = ga_hosp_date)

write.csv(ga_hosp_out, "~/work/COVID-19-DATA/US/COVID-19-ILI-forecasting/data/COVID-NET-hospitalization-georgia-formatted.csv")
