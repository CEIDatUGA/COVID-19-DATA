

## Loading govex vaccination data timeseries

library(readr)

# set working directory to COVID-19-DATA repo
setwd("~/work/COVID-19-DATA")


urlfile <- "https://raw.githubusercontent.com/govex/COVID-19/master/data_tables/vaccine_data/raw_data/vaccine_data_us_state_timeline.csv"

govex_vacc <- read_csv(url(urlfile))

write_csv(govex_vacc, "US/us-vaccine-data/state-vaccine-data-govex/vaccine_data_us_state_timeline.csv")

data_dict_url <- "https://raw.githubusercontent.com/govex/COVID-19/master/data_tables/vaccine_data/raw_data/data_dictionary.csv"

govex_data_dict <- read_csv(url(data_dict_url))

write_csv(govex_data_dict, "US/us-vaccine-data/state-vaccine-data-govex/govex-data-dictionary.csv")

#download the readme to get the urls for each state dashboard they use for data sources
download.file("https://raw.githubusercontent.com/govex/COVID-19/master/data_tables/vaccine_data/readme.md", "US/us-vaccine-data/state-vaccine-data-govex/readme.md")

