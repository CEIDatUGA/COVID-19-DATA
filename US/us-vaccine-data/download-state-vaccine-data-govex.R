

## Loading govex vaccination data timeseries

library(readr)

# set working directory to COVID-19-DATA repo
setwd("~/work/COVID-19-DATA")


urlfile="https://raw.githubusercontent.com/govex/COVID-19/master/data_tables/vaccine_data/raw_data/vaccine_data_us_state_timeline.csv"

govex_vacc <- read_csv(url(urlfile))

write_csv(govex_vacc, "US/us-vaccine-data/state-vaccine-data-govex/vaccine_data_us_state_timeline.csv")




