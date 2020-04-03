### This script reads the human scraped data on state interventions
### Originated by: Robbie Richards
### Originated on: 3/18/2020

# Load necessary packages
library(tidyr)
library(dplyr)
library(googledrive)
library(googlesheets4)
library(lubridate)

# Set user info and read in google sheet
options(gargle_oauth_email = "robbielrichards@gmail.com")
df <- read_sheet("https://docs.google.com/spreadsheets/d/1UZMWpbebhI3HS2BwzK0PCUxAbypYnM9oA9t9jP6zNXE/edit#gid=1772124213", range = "ga-intervention-announcements", col_types = "c")
  

# Set start_date column to a date object
df <- df %>%  
  mutate(start_date = ymd(as.character(start_date)), announcement_date = ymd(announcement_date), end_date = ymd(end_date))



# Immediately write the flat csv from the google sheet
write.csv(df, "GA_raw_county_interventions.csv")

# Next we build the time series dataframe
# We first build an empty data frame as long as the number of dates since the first of February multiplied by the number of counties
# Columns are named for all intervention types

dates <- seq.Date(from = ymd("2020-02-01"), to = ymd(format(Sys.time(), '%Y-%m-%d')), by =1) 
dfTS <- data.frame(matrix(0, nrow= length(levels(factor(df$NAME)))*length(dates), ncol = 23))
names(dfTS) <- c("NAME", "DATE", "mandatory_traveler_quarantine","prohibit_restaurants","prohibit_business", "non-contact_school", "state_of_emergency", "gathering_size_limited", "public_health_emergency", "shelter_in_place", "travel_screening","close_public_spaces", "social_distancing","gathering_size", "monitoring", "well_being", "animal_distancing", "non_contact_infrastructure", "prohibit_travel", "international_travel_quarantine", "protect_high_risk_populations", "personal_hygiene", "environmental_hygiene")
dates <- seq.Date(from = ymd("2020-02-01"), to = ymd(format(Sys.time(), '%Y-%m-%d'))+1, by =1/length(levels(factor(df$NAME)))) 

# For entries in the raw df without a start_date set the start_date to the announcement_date
for(i in 1:nrow(df)){
  if(is.na(df$start_date[i])){
    df$start_date[i] <- df$announcement_date[i]
  }
}
# Fill the county name and date columns of the timeseries data frame
dfTS$NAME<- levels(factor(df$NAME))
dfTS$DATE <- as.character(dates[-1])

# Remove all rows of the raw dataframe that remain without a start_date
df <- df %>% filter(!is.na(start_date)) %>%
  mutate(start_date = ymd(start_date), announcement_date = ymd(announcement_date), end_date = ymd(end_date))


#Set gathering size maximum to NA for the time series (instead of zero)
dfTS$gathering_size <- NA


# This is big ol' for loop because I couldn't figure out a better way to do it 
# First we make a list of counties and loop over all county names
counties <- list()
for(i in 1: length(levels(factor(dfTS$NAME)))){
  # Then for each county we fill the counties list item with all entries in the time series for that county
  # And fix the dates again...
  counties[[i]] <- filter(dfTS, NAME == levels(factor(dfTS$NAME))[i]) %>%
    mutate(DATE = ymd(DATE))
  # Then we filter the raw dataset to just the entries in that county
  countyAnnouncements <- filter(df,NAME ==  levels(factor(dfTS$NAME))[i])
  
  # Next we go through each intervention type to fill in the time series for that county
  # I'm just going to fully comment the first one
  
  #prohibit_restaurants
  
  # We filter the raw data for the county to just those entries with the appropriate intervention type
  subAnnouncements <- filter(countyAnnouncements, intervention_type == "prohibit_restaurants")
  
  # Then if there are any announcements
  if(nrow(subAnnouncements)>0){
    
    # We iterate over all all appropriate announcements
    for(j in 1:nrow(subAnnouncements)){
      # If there isn't an end_date for an announcement and there are no other announcements fill it with the present date
      if(is.na(subAnnouncements$end_date[j]) & nrow(subAnnouncements)==1){subAnnouncements$end_date[j] <- ymd(format(Sys.time(), '%Y-%m-%d'))+1}
      # This anticipates all future records being entered with a valid start date and not just as an end date
      # But it also will allow us to more easily deal with on and off measures I think
      # If there isn't an end_date for an announcement and there are other announcements of this type then it sets the end_date to the latest start_date of the announcements
      if(is.na(subAnnouncements$end_date[j]) & nrow(subAnnouncements)>1){subAnnouncements$end_date[j] <- max(subAnnouncements$start_date, na.rm=T)}
      # This catches if there were multiple rows but the latest announcement lacked an end date and as a result the end_date was filled in as the start_date for that entry
      # It then fills in the present date instead of the start_date
      if(subAnnouncements$end_date[j] == subAnnouncements$start_date[j]){subAnnouncements$end_date[j] <- ymd(format(Sys.time(), '%Y-%m-%d'))+1}
      # This just catches if all the other end_dates were also NA and fills in today as end date
      if(is.na(subAnnouncements$end_date[j])|is.infinite(subAnnouncements$end_date[j])){subAnnouncements$end_date[j] <- ymd(format(Sys.time(), '%Y-%m-%d'))+1}
      # Creates a date interval for each announcement between the start_date and end_date
      announceInterval <- lubridate::interval(subAnnouncements$start_date[j], subAnnouncements$end_date[j])
      # Then get the indices for the rows in the time series which are inside that interval
      inside <- which(counties[[i]]$DATE %within% announceInterval)
      # And set the entries in those rows and the apporpriate announcement type column to 1
      counties[[i]]$prohibit_restaurants[inside] <- 1
      # Repeating this for each announcement of this type will fill in all the necessary 1s
    }
  }
  #non-contact_school
  subAnnouncements <- filter(countyAnnouncements, intervention_type == "no_contact_school"|intervention_type =="non-contact school")
  if(nrow(subAnnouncements)>0){
    for(j in 1:nrow(subAnnouncements)){
      # If there isn't an end_date for an announcement and there are no other announcements fill it with the present date
      if(is.na(subAnnouncements$end_date[j]) & nrow(subAnnouncements)==1){subAnnouncements$end_date[j] <- ymd(format(Sys.time(), '%Y-%m-%d'))+1}
      # This anticipates all future records being entered with a valid start date and not just as an end date
      # But it also will allow us to more easily deal with on and off measures I think
      # If there isn't an end_date for an announcement and there are other announcements of this type then it sets the end_date to the latest start_date of the announcements
      if(is.na(subAnnouncements$end_date[j]) & nrow(subAnnouncements)>1){subAnnouncements$end_date[j] <- max(subAnnouncements$start_date, na.rm=T)}
      # This catches if there were multiple rows but the latest announcement lacked an end date and as a result the end_date was filled in as the start_date for that entry
      # It then fills in the present date instead of the start_date
      if(subAnnouncements$end_date[j] == subAnnouncements$start_date[j]){subAnnouncements$end_date[j] <- ymd(format(Sys.time(), '%Y-%m-%d'))+1}
      # This just catches if all the other end_dates were also NA and fills in today as end date
      if(is.na(subAnnouncements$end_date[j])|is.infinite(subAnnouncements$end_date[j])){subAnnouncements$end_date[j] <- ymd(format(Sys.time(), '%Y-%m-%d'))+1}
      # Creates a date interval for each announcement between the start_date and end_date
      announceInterval <- lubridate::interval(subAnnouncements$start_date[j], subAnnouncements$end_date[j])
      # Then get the indices for the rows in the time series which are inside that interval
      inside <- which(counties[[i]]$DATE %within% announceInterval)
      # And set the entries in those rows and the apporpriate announcement type column to 1
      counties[[i]]$`non-contact_school`[inside] <- 1
    }
  }
  #environmental_hygiene
  subAnnouncements <- filter(countyAnnouncements, intervention_type == "environmental_hygiene")
  if(nrow(subAnnouncements)>0){
    for(j in 1:nrow(subAnnouncements)){
      # If there isn't an end_date for an announcement and there are no other announcements fill it with the present date
      if(is.na(subAnnouncements$end_date[j]) & nrow(subAnnouncements)==1){subAnnouncements$end_date[j] <- ymd(format(Sys.time(), '%Y-%m-%d'))+1}
      # This anticipates all future records being entered with a valid start date and not just as an end date
      # But it also will allow us to more easily deal with on and off measures I think
      # If there isn't an end_date for an announcement and there are other announcements of this type then it sets the end_date to the latest start_date of the announcements
      if(is.na(subAnnouncements$end_date[j]) & nrow(subAnnouncements)>1){subAnnouncements$end_date[j] <- max(subAnnouncements$start_date, na.rm=T)}
      # This catches if there were multiple rows but the latest announcement lacked an end date and as a result the end_date was filled in as the start_date for that entry
      # It then fills in the present date instead of the start_date
      if(subAnnouncements$end_date[j] == subAnnouncements$start_date[j]){subAnnouncements$end_date[j] <- ymd(format(Sys.time(), '%Y-%m-%d'))+1}
      # This just catches if all the other end_dates were also NA and fills in today as end date
      if(is.na(subAnnouncements$end_date[j])|is.infinite(subAnnouncements$end_date[j])){subAnnouncements$end_date[j] <- ymd(format(Sys.time(), '%Y-%m-%d'))+1}
      # Creates a date interval for each announcement between the start_date and end_date
      announceInterval <- lubridate::interval(subAnnouncements$start_date[j], subAnnouncements$end_date[j])
      # Then get the indices for the rows in the time series which are inside that interval
      inside <- which(counties[[i]]$DATE %within% announceInterval)
      # And set the entries in those rows and the apporpriate announcement type column to 1
      counties[[i]]$environmental_hygiene[inside] <- 1
    }
  }
  #close_public_spaces
  subAnnouncements <- filter(countyAnnouncements, intervention_type == "close_public spaces"|intervention_type =="close_public_spaces")
  if(nrow(subAnnouncements)>0){
    for(j in 1:nrow(subAnnouncements)){
      # If there isn't an end_date for an announcement and there are no other announcements fill it with the present date
      if(is.na(subAnnouncements$end_date[j]) & nrow(subAnnouncements)==1){subAnnouncements$end_date[j] <- ymd(format(Sys.time(), '%Y-%m-%d'))+1}
      # This anticipates all future records being entered with a valid start date and not just as an end date
      # But it also will allow us to more easily deal with on and off measures I think
      # If there isn't an end_date for an announcement and there are other announcements of this type then it sets the end_date to the latest start_date of the announcements
      if(is.na(subAnnouncements$end_date[j]) & nrow(subAnnouncements)>1){subAnnouncements$end_date[j] <- max(subAnnouncements$start_date, na.rm=T)}
      # This catches if there were multiple rows but the latest announcement lacked an end date and as a result the end_date was filled in as the start_date for that entry
      # It then fills in the present date instead of the start_date
      if(subAnnouncements$end_date[j] == subAnnouncements$start_date[j]){subAnnouncements$end_date[j] <- ymd(format(Sys.time(), '%Y-%m-%d'))+1}
      # This just catches if all the other end_dates were also NA and fills in today as end date
      if(is.na(subAnnouncements$end_date[j])|is.infinite(subAnnouncements$end_date[j])){subAnnouncements$end_date[j] <- ymd(format(Sys.time(), '%Y-%m-%d'))+1}
      # Creates a date interval for each announcement between the start_date and end_date
      announceInterval <- lubridate::interval(subAnnouncements$start_date[j], subAnnouncements$end_date[j])
      # Then get the indices for the rows in the time series which are inside that interval
      inside <- which(counties[[i]]$DATE %within% announceInterval)
      # And set the entries in those rows and the apporpriate announcement type column to 1
      counties[[i]]$close_public_spaces[inside] <- 1
    }
  }
  #gathering_size_limited
  subAnnouncements <- filter(countyAnnouncements, intervention_type == "gathering_size_limited")
  if(nrow(subAnnouncements)>0){
    for(j in 1:nrow(subAnnouncements)){
      # If there isn't an end_date for an announcement and there are no other announcements fill it with the present date
      if(is.na(subAnnouncements$end_date[j]) & nrow(subAnnouncements)==1){subAnnouncements$end_date[j] <- ymd(format(Sys.time(), '%Y-%m-%d'))+1}
      # This anticipates all future records being entered with a valid start date and not just as an end date
      # But it also will allow us to more easily deal with on and off measures I think
      # If there isn't an end_date for an announcement and there are other announcements of this type then it sets the end_date to the latest start_date of the announcements
      if(is.na(subAnnouncements$end_date[j]) & nrow(subAnnouncements)>1){subAnnouncements$end_date[j] <- max(subAnnouncements$start_date, na.rm=T)}
      # This catches if there were multiple rows but the latest announcement lacked an end date and as a result the end_date was filled in as the start_date for that entry
      # It then fills in the present date instead of the start_date
      if(subAnnouncements$end_date[j] == subAnnouncements$start_date[j]){subAnnouncements$end_date[j] <- ymd(format(Sys.time(), '%Y-%m-%d'))+1}
      # This just catches if all the other end_dates were also NA and fills in today as end date
      if(is.na(subAnnouncements$end_date[j])|is.infinite(subAnnouncements$end_date[j])){subAnnouncements$end_date[j] <- ymd(format(Sys.time(), '%Y-%m-%d'))+1}
      # Creates a date interval for each announcement between the start_date and end_date
      announceInterval <- lubridate::interval(subAnnouncements$start_date[j], subAnnouncements$end_date[j])
      # Then get the indices for the rows in the time series which are inside that interval
      inside <- which(counties[[i]]$DATE %within% announceInterval)
      # And set the entries in those rows and the apporpriate announcement type column to 1
      counties[[i]]$gathering_size_limited[inside] <- 1
      ### For gathering_size we add in that the store the appropriate gathering size for the interval here
      counties[[i]]$gathering_size[inside] <-subAnnouncements$gathering_size[j]
    }
  }
  
  #personal_hygiene
  subAnnouncements <- filter(countyAnnouncements, intervention_type == "personal_hygiene")
  if(nrow(subAnnouncements)>0){
    for(j in 1:nrow(subAnnouncements)){
      # If there isn't an end_date for an announcement and there are no other announcements fill it with the present date
      if(is.na(subAnnouncements$end_date[j]) & nrow(subAnnouncements)==1){subAnnouncements$end_date[j] <- ymd(format(Sys.time(), '%Y-%m-%d'))+1}
      # This anticipates all future records being entered with a valid start date and not just as an end date
      # But it also will allow us to more easily deal with on and off measures I think
      # If there isn't an end_date for an announcement and there are other announcements of this type then it sets the end_date to the latest start_date of the announcements
      if(is.na(subAnnouncements$end_date[j]) & nrow(subAnnouncements)>1){subAnnouncements$end_date[j] <- max(subAnnouncements$start_date, na.rm=T)}
      # This catches if there were multiple rows but the latest announcement lacked an end date and as a result the end_date was filled in as the start_date for that entry
      # It then fills in the present date instead of the start_date
      if(subAnnouncements$end_date[j] == subAnnouncements$start_date[j]){subAnnouncements$end_date[j] <- ymd(format(Sys.time(), '%Y-%m-%d'))+1}
      # This just catches if all the other end_dates were also NA and fills in today as end date
      if(is.na(subAnnouncements$end_date[j])|is.infinite(subAnnouncements$end_date[j])){subAnnouncements$end_date[j] <- ymd(format(Sys.time(), '%Y-%m-%d'))+1}
      # Creates a date interval for each announcement between the start_date and end_date
      announceInterval <- lubridate::interval(subAnnouncements$start_date[j], subAnnouncements$end_date[j])
      # Then get the indices for the rows in the time series which are inside that interval
      inside <- which(counties[[i]]$DATE %within% announceInterval)
      # And set the entries in those rows and the apporpriate announcement type column to 1
      counties[[i]]$personal_hygiene[inside] <- 1
    }
  }
  #prohibit_business
  subAnnouncements <- filter(countyAnnouncements, intervention_type == "prohibit_business")
  if(nrow(subAnnouncements)>0){
    for(j in 1:nrow(subAnnouncements)){
      # If there isn't an end_date for an announcement and there are no other announcements fill it with the present date
      if(is.na(subAnnouncements$end_date[j]) & nrow(subAnnouncements)==1){subAnnouncements$end_date[j] <- ymd(format(Sys.time(), '%Y-%m-%d'))+1}
      # This anticipates all future records being entered with a valid start date and not just as an end date
      # But it also will allow us to more easily deal with on and off measures I think
      # If there isn't an end_date for an announcement and there are other announcements of this type then it sets the end_date to the latest start_date of the announcements
      if(is.na(subAnnouncements$end_date[j]) & nrow(subAnnouncements)>1){subAnnouncements$end_date[j] <- max(subAnnouncements$start_date, na.rm=T)}
      # This catches if there were multiple rows but the latest announcement lacked an end date and as a result the end_date was filled in as the start_date for that entry
      # It then fills in the present date instead of the start_date
      if(subAnnouncements$end_date[j] == subAnnouncements$start_date[j]){subAnnouncements$end_date[j] <- ymd(format(Sys.time(), '%Y-%m-%d'))+1}
      # This just catches if all the other end_dates were also NA and fills in today as end date
      if(is.na(subAnnouncements$end_date[j])|is.infinite(subAnnouncements$end_date[j])){subAnnouncements$end_date[j] <- ymd(format(Sys.time(), '%Y-%m-%d'))+1}
      # Creates a date interval for each announcement between the start_date and end_date
      announceInterval <- lubridate::interval(subAnnouncements$start_date[j], subAnnouncements$end_date[j])
      # Then get the indices for the rows in the time series which are inside that interval
      inside <- which(counties[[i]]$DATE %within% announceInterval)
      # And set the entries in those rows and the apporpriate announcement type column to 1
      counties[[i]]$prohibit_business[inside] <- 1
    }
  }
  #shelter_in_place
  subAnnouncements <- filter(countyAnnouncements, intervention_type == "shelter_in_place")
  if(nrow(subAnnouncements)>0){
    for(j in 1:nrow(subAnnouncements)){
      # If there isn't an end_date for an announcement and there are no other announcements fill it with the present date
      if(is.na(subAnnouncements$end_date[j]) & nrow(subAnnouncements)==1){subAnnouncements$end_date[j] <- ymd(format(Sys.time(), '%Y-%m-%d'))+1}
      # This anticipates all future records being entered with a valid start date and not just as an end date
      # But it also will allow us to more easily deal with on and off measures I think
      # If there isn't an end_date for an announcement and there are other announcements of this type then it sets the end_date to the latest start_date of the announcements
      if(is.na(subAnnouncements$end_date[j]) & nrow(subAnnouncements)>1){subAnnouncements$end_date[j] <- max(subAnnouncements$start_date, na.rm=T)}
      # This catches if there were multiple rows but the latest announcement lacked an end date and as a result the end_date was filled in as the start_date for that entry
      # It then fills in the present date instead of the start_date
      if(subAnnouncements$end_date[j] == subAnnouncements$start_date[j]){subAnnouncements$end_date[j] <- ymd(format(Sys.time(), '%Y-%m-%d'))+1}
      # This just catches if all the other end_dates were also NA and fills in today as end date
      if(is.na(subAnnouncements$end_date[j])|is.infinite(subAnnouncements$end_date[j])){subAnnouncements$end_date[j] <- ymd(format(Sys.time(), '%Y-%m-%d'))+1}
      # Creates a date interval for each announcement between the start_date and end_date
      announceInterval <- lubridate::interval(subAnnouncements$start_date[j], subAnnouncements$end_date[j])
      # Then get the indices for the rows in the time series which are inside that interval
      inside <- which(counties[[i]]$DATE %within% announceInterval)
      # And set the entries in those rows and the apporpriate announcement type column to 1
      counties[[i]]$shelter_in_place[inside] <- 1
    }
  }
  #social_distancing
  subAnnouncements <- filter(countyAnnouncements, intervention_type == "social_distancing")
  if(nrow(subAnnouncements)>0){
    for(j in 1:nrow(subAnnouncements)){
      # If there isn't an end_date for an announcement and there are no other announcements fill it with the present date
      if(is.na(subAnnouncements$end_date[j]) & nrow(subAnnouncements)==1){subAnnouncements$end_date[j] <- ymd(format(Sys.time(), '%Y-%m-%d'))+1}
      # This anticipates all future records being entered with a valid start date and not just as an end date
      # But it also will allow us to more easily deal with on and off measures I think
      # If there isn't an end_date for an announcement and there are other announcements of this type then it sets the end_date to the latest start_date of the announcements
      if(is.na(subAnnouncements$end_date[j]) & nrow(subAnnouncements)>1){subAnnouncements$end_date[j] <- max(subAnnouncements$start_date, na.rm=T)}
      # This catches if there were multiple rows but the latest announcement lacked an end date and as a result the end_date was filled in as the start_date for that entry
      # It then fills in the present date instead of the start_date
      if(subAnnouncements$end_date[j] == subAnnouncements$start_date[j]){subAnnouncements$end_date[j] <- ymd(format(Sys.time(), '%Y-%m-%d'))+1}
      # This just catches if all the other end_dates were also NA and fills in today as end date
      if(is.na(subAnnouncements$end_date[j])|is.infinite(subAnnouncements$end_date[j])){subAnnouncements$end_date[j] <- ymd(format(Sys.time(), '%Y-%m-%d'))+1}
      # Creates a date interval for each announcement between the start_date and end_date
      announceInterval <- lubridate::interval(subAnnouncements$start_date[j], subAnnouncements$end_date[j])
      # Then get the indices for the rows in the time series which are inside that interval
      inside <- which(counties[[i]]$DATE %within% announceInterval)
      # And set the entries in those rows and the apporpriate announcement type column to 1
      counties[[i]]$social_distancing[inside] <- 1
    }
  }
  #state_of_emergency
  subAnnouncements <- filter(countyAnnouncements, intervention_type == "state_of_emergency"|intervention_type == "state of emergency")
  if(nrow(subAnnouncements)>0){
    for(j in 1:nrow(subAnnouncements)){
      # If there isn't an end_date for an announcement and there are no other announcements fill it with the present date
      if(is.na(subAnnouncements$end_date[j]) & nrow(subAnnouncements)==1){subAnnouncements$end_date[j] <- ymd(format(Sys.time(), '%Y-%m-%d'))+1}
      # This anticipates all future records being entered with a valid start date and not just as an end date
      # But it also will allow us to more easily deal with on and off measures I think
      # If there isn't an end_date for an announcement and there are other announcements of this type then it sets the end_date to the latest start_date of the announcements
      if(is.na(subAnnouncements$end_date[j]) & nrow(subAnnouncements)>1){subAnnouncements$end_date[j] <- max(subAnnouncements$start_date, na.rm=T)}
      # This catches if there were multiple rows but the latest announcement lacked an end date and as a result the end_date was filled in as the start_date for that entry
      # It then fills in the present date instead of the start_date
      if(subAnnouncements$end_date[j] == subAnnouncements$start_date[j]){subAnnouncements$end_date[j] <- ymd(format(Sys.time(), '%Y-%m-%d'))+1}
      # This just catches if all the other end_dates were also NA and fills in today as end date
      if(is.na(subAnnouncements$end_date[j])|is.infinite(subAnnouncements$end_date[j])){subAnnouncements$end_date[j] <- ymd(format(Sys.time(), '%Y-%m-%d'))+1}
      # Creates a date interval for each announcement between the start_date and end_date
      announceInterval <- lubridate::interval(subAnnouncements$start_date[j], subAnnouncements$end_date[j])
      # Then get the indices for the rows in the time series which are inside that interval
      inside <- which(counties[[i]]$DATE %within% announceInterval)
      # And set the entries in those rows and the apporpriate announcement type column to 1
      counties[[i]]$state_of_emergency[inside] <- 1
    }
  }
  #monitoring
  subAnnouncements <- filter(countyAnnouncements, intervention_type == "monitoring")
  if(nrow(subAnnouncements)>0){
    for(j in 1:nrow(subAnnouncements)){
      # If there isn't an end_date for an announcement and there are no other announcements fill it with the present date
      if(is.na(subAnnouncements$end_date[j]) & nrow(subAnnouncements)==1){subAnnouncements$end_date[j] <- ymd(format(Sys.time(), '%Y-%m-%d'))+1}
      # This anticipates all future records being entered with a valid start date and not just as an end date
      # But it also will allow us to more easily deal with on and off measures I think
      # If there isn't an end_date for an announcement and there are other announcements of this type then it sets the end_date to the latest start_date of the announcements
      if(is.na(subAnnouncements$end_date[j]) & nrow(subAnnouncements)>1){subAnnouncements$end_date[j] <- max(subAnnouncements$start_date, na.rm=T)}
      # This catches if there were multiple rows but the latest announcement lacked an end date and as a result the end_date was filled in as the start_date for that entry
      # It then fills in the present date instead of the start_date
      if(subAnnouncements$end_date[j] == subAnnouncements$start_date[j]){subAnnouncements$end_date[j] <- ymd(format(Sys.time(), '%Y-%m-%d'))+1}
      # This just catches if all the other end_dates were also NA and fills in today as end date
      if(is.na(subAnnouncements$end_date[j])|is.infinite(subAnnouncements$end_date[j])){subAnnouncements$end_date[j] <- ymd(format(Sys.time(), '%Y-%m-%d'))+1}
      # Creates a date interval for each announcement between the start_date and end_date
      announceInterval <- lubridate::interval(subAnnouncements$start_date[j], subAnnouncements$end_date[j])
      # Then get the indices for the rows in the time series which are inside that interval
      inside <- which(counties[[i]]$DATE %within% announceInterval)
      # And set the entries in those rows and the apporpriate announcement type column to 1
      counties[[i]]$monitoring[inside] <- 1
    }
  }
  #well_being
  subAnnouncements <- filter(countyAnnouncements, intervention_type == "well_being")
  if(nrow(subAnnouncements)>0){
    for(j in 1:nrow(subAnnouncements)){
      # If there isn't an end_date for an announcement and there are no other announcements fill it with the present date
      if(is.na(subAnnouncements$end_date[j]) & nrow(subAnnouncements)==1){subAnnouncements$end_date[j] <- ymd(format(Sys.time(), '%Y-%m-%d'))+1}
      # This anticipates all future records being entered with a valid start date and not just as an end date
      # But it also will allow us to more easily deal with on and off measures I think
      # If there isn't an end_date for an announcement and there are other announcements of this type then it sets the end_date to the latest start_date of the announcements
      if(is.na(subAnnouncements$end_date[j]) & nrow(subAnnouncements)>1){subAnnouncements$end_date[j] <- max(subAnnouncements$start_date, na.rm=T)}
      # This catches if there were multiple rows but the latest announcement lacked an end date and as a result the end_date was filled in as the start_date for that entry
      # It then fills in the present date instead of the start_date
      if(subAnnouncements$end_date[j] == subAnnouncements$start_date[j]){subAnnouncements$end_date[j] <- ymd(format(Sys.time(), '%Y-%m-%d'))+1}
      # This just catches if all the other end_dates were also NA and fills in today as end date
      if(is.na(subAnnouncements$end_date[j])|is.infinite(subAnnouncements$end_date[j])){subAnnouncements$end_date[j] <- ymd(format(Sys.time(), '%Y-%m-%d'))+1}
      # Creates a date interval for each announcement between the start_date and end_date
      announceInterval <- lubridate::interval(subAnnouncements$start_date[j], subAnnouncements$end_date[j])
      # Then get the indices for the rows in the time series which are inside that interval
      inside <- which(counties[[i]]$DATE %within% announceInterval)
      # And set the entries in those rows and the apporpriate announcement type column to 1
      counties[[i]]$well_being[inside] <- 1
    }
  }
  #animal_distancing
  subAnnouncements <- filter(countyAnnouncements, intervention_type == "animal_distancing")
  if(nrow(subAnnouncements)>0){
    for(j in 1:nrow(subAnnouncements)){
      # If there isn't an end_date for an announcement and there are no other announcements fill it with the present date
      if(is.na(subAnnouncements$end_date[j]) & nrow(subAnnouncements)==1){subAnnouncements$end_date[j] <- ymd(format(Sys.time(), '%Y-%m-%d'))+1}
      # This anticipates all future records being entered with a valid start date and not just as an end date
      # But it also will allow us to more easily deal with on and off measures I think
      # If there isn't an end_date for an announcement and there are other announcements of this type then it sets the end_date to the latest start_date of the announcements
      if(is.na(subAnnouncements$end_date[j]) & nrow(subAnnouncements)>1){subAnnouncements$end_date[j] <- max(subAnnouncements$start_date, na.rm=T)}
      # This catches if there were multiple rows but the latest announcement lacked an end date and as a result the end_date was filled in as the start_date for that entry
      # It then fills in the present date instead of the start_date
      if(subAnnouncements$end_date[j] == subAnnouncements$start_date[j]){subAnnouncements$end_date[j] <- ymd(format(Sys.time(), '%Y-%m-%d'))+1}
      # This just catches if all the other end_dates were also NA and fills in today as end date
      if(is.na(subAnnouncements$end_date[j])|is.infinite(subAnnouncements$end_date[j])){subAnnouncements$end_date[j] <- ymd(format(Sys.time(), '%Y-%m-%d'))+1}
      # Creates a date interval for each announcement between the start_date and end_date
      announceInterval <- lubridate::interval(subAnnouncements$start_date[j], subAnnouncements$end_date[j])
      # Then get the indices for the rows in the time series which are inside that interval
      inside <- which(counties[[i]]$DATE %within% announceInterval)
      # And set the entries in those rows and the apporpriate announcement type column to 1
      counties[[i]]$animal_distancing[inside] <- 1
    }
  }
  #non_contact_infrastructure
  subAnnouncements <- filter(countyAnnouncements, intervention_type == "non_contact_infrastructure")
  if(nrow(subAnnouncements)>0){
    for(j in 1:nrow(subAnnouncements)){
      # If there isn't an end_date for an announcement and there are no other announcements fill it with the present date
      if(is.na(subAnnouncements$end_date[j]) & nrow(subAnnouncements)==1){subAnnouncements$end_date[j] <- ymd(format(Sys.time(), '%Y-%m-%d'))+1}
      # This anticipates all future records being entered with a valid start date and not just as an end date
      # But it also will allow us to more easily deal with on and off measures I think
      # If there isn't an end_date for an announcement and there are other announcements of this type then it sets the end_date to the latest start_date of the announcements
      if(is.na(subAnnouncements$end_date[j]) & nrow(subAnnouncements)>1){subAnnouncements$end_date[j] <- max(subAnnouncements$start_date, na.rm=T)}
      # This catches if there were multiple rows but the latest announcement lacked an end date and as a result the end_date was filled in as the start_date for that entry
      # It then fills in the present date instead of the start_date
      if(subAnnouncements$end_date[j] == subAnnouncements$start_date[j]){subAnnouncements$end_date[j] <- ymd(format(Sys.time(), '%Y-%m-%d'))+1}
      # This just catches if all the other end_dates were also NA and fills in today as end date
      if(is.na(subAnnouncements$end_date[j])|is.infinite(subAnnouncements$end_date[j])){subAnnouncements$end_date[j] <- ymd(format(Sys.time(), '%Y-%m-%d'))+1}
      # Creates a date interval for each announcement between the start_date and end_date
      announceInterval <- lubridate::interval(subAnnouncements$start_date[j], subAnnouncements$end_date[j])
      # Then get the indices for the rows in the time series which are inside that interval
      inside <- which(counties[[i]]$DATE %within% announceInterval)
      # And set the entries in those rows and the apporpriate announcement type column to 1
      counties[[i]]$non_contact_infrastructure[inside] <- 1
    }
  }
  #prohibit_travel
  subAnnouncements <- filter(countyAnnouncements, intervention_type == "prohibit_travel")
  if(nrow(subAnnouncements)>0){
    for(j in 1:nrow(subAnnouncements)){
      # If there isn't an end_date for an announcement and there are no other announcements fill it with the present date
      if(is.na(subAnnouncements$end_date[j]) & nrow(subAnnouncements)==1){subAnnouncements$end_date[j] <- ymd(format(Sys.time(), '%Y-%m-%d'))+1}
      # This anticipates all future records being entered with a valid start date and not just as an end date
      # But it also will allow us to more easily deal with on and off measures I think
      # If there isn't an end_date for an announcement and there are other announcements of this type then it sets the end_date to the latest start_date of the announcements
      if(is.na(subAnnouncements$end_date[j]) & nrow(subAnnouncements)>1){subAnnouncements$end_date[j] <- max(subAnnouncements$start_date, na.rm=T)}
      # This catches if there were multiple rows but the latest announcement lacked an end date and as a result the end_date was filled in as the start_date for that entry
      # It then fills in the present date instead of the start_date
      if(subAnnouncements$end_date[j] == subAnnouncements$start_date[j]){subAnnouncements$end_date[j] <- ymd(format(Sys.time(), '%Y-%m-%d'))+1}
      # This just catches if all the other end_dates were also NA and fills in today as end date
      if(is.na(subAnnouncements$end_date[j])|is.infinite(subAnnouncements$end_date[j])){subAnnouncements$end_date[j] <- ymd(format(Sys.time(), '%Y-%m-%d'))+1}
      # Creates a date interval for each announcement between the start_date and end_date
      announceInterval <- lubridate::interval(subAnnouncements$start_date[j], subAnnouncements$end_date[j])
      # Then get the indices for the rows in the time series which are inside that interval
      inside <- which(counties[[i]]$DATE %within% announceInterval)
      # And set the entries in those rows and the apporpriate announcement type column to 1
      counties[[i]]$prohibit_travel[inside] <- 1
    }
  }
  #international_travel_quarantine
  subAnnouncements <- filter(countyAnnouncements, intervention_type == "international_travel_quarantine")
  if(nrow(subAnnouncements)>0){
    for(j in 1:nrow(subAnnouncements)){
      # If there isn't an end_date for an announcement and there are no other announcements fill it with the present date
      if(is.na(subAnnouncements$end_date[j]) & nrow(subAnnouncements)==1){subAnnouncements$end_date[j] <- ymd(format(Sys.time(), '%Y-%m-%d'))+1}
      # This anticipates all future records being entered with a valid start date and not just as an end date
      # But it also will allow us to more easily deal with on and off measures I think
      # If there isn't an end_date for an announcement and there are other announcements of this type then it sets the end_date to the latest start_date of the announcements
      if(is.na(subAnnouncements$end_date[j]) & nrow(subAnnouncements)>1){subAnnouncements$end_date[j] <- max(subAnnouncements$start_date, na.rm=T)}
      # This catches if there were multiple rows but the latest announcement lacked an end date and as a result the end_date was filled in as the start_date for that entry
      # It then fills in the present date instead of the start_date
      if(subAnnouncements$end_date[j] == subAnnouncements$start_date[j]){subAnnouncements$end_date[j] <- ymd(format(Sys.time(), '%Y-%m-%d'))+1}
      # This just catches if all the other end_dates were also NA and fills in today as end date
      if(is.na(subAnnouncements$end_date[j])|is.infinite(subAnnouncements$end_date[j])){subAnnouncements$end_date[j] <- ymd(format(Sys.time(), '%Y-%m-%d'))+1}
      # Creates a date interval for each announcement between the start_date and end_date
      announceInterval <- lubridate::interval(subAnnouncements$start_date[j], subAnnouncements$end_date[j])
      # Then get the indices for the rows in the time series which are inside that interval
      inside <- which(counties[[i]]$DATE %within% announceInterval)
      # And set the entries in those rows and the apporpriate announcement type column to 1
      counties[[i]]$international_travel_quarantine[inside] <- 1
    }
  }
  #protect_high_risk_populations
  subAnnouncements <- filter(countyAnnouncements, intervention_type == "protect_high_risk_populations")
  if(nrow(subAnnouncements)>0){
    for(j in 1:nrow(subAnnouncements)){
      # If there isn't an end_date for an announcement and there are no other announcements fill it with the present date
      if(is.na(subAnnouncements$end_date[j]) & nrow(subAnnouncements)==1){subAnnouncements$end_date[j] <- ymd(format(Sys.time(), '%Y-%m-%d'))+1}
      # This anticipates all future records being entered with a valid start date and not just as an end date
      # But it also will allow us to more easily deal with on and off measures I think
      # If there isn't an end_date for an announcement and there are other announcements of this type then it sets the end_date to the latest start_date of the announcements
      if(is.na(subAnnouncements$end_date[j]) & nrow(subAnnouncements)>1){subAnnouncements$end_date[j] <- max(subAnnouncements$start_date, na.rm=T)}
      # This catches if there were multiple rows but the latest announcement lacked an end date and as a result the end_date was filled in as the start_date for that entry
      # It then fills in the present date instead of the start_date
      if(subAnnouncements$end_date[j] == subAnnouncements$start_date[j]){subAnnouncements$end_date[j] <- ymd(format(Sys.time(), '%Y-%m-%d'))+1}
      # This just catches if all the other end_dates were also NA and fills in today as end date
      if(is.na(subAnnouncements$end_date[j])|is.infinite(subAnnouncements$end_date[j])){subAnnouncements$end_date[j] <- ymd(format(Sys.time(), '%Y-%m-%d'))+1}
      # Creates a date interval for each announcement between the start_date and end_date
      announceInterval <- lubridate::interval(subAnnouncements$start_date[j], subAnnouncements$end_date[j])
      # Then get the indices for the rows in the time series which are inside that interval
      inside <- which(counties[[i]]$DATE %within% announceInterval)
      # And set the entries in those rows and the apporpriate announcement type column to 1
      counties[[i]]$protect_high_risk_populations[inside] <- 1
    }
  }
}

# We then bind all the counties in each list entry into a single timeseries dataframe
dfTS <- bind_rows(counties)

# Finally we compute the intervention score using the impact scores from the metadata in the google sheet
dfTS <- dfTS %>%
  mutate(Intervention_Score = social_distancing*.25+ close_public_spaces+ personal_hygiene*.25+ environmental_hygiene*.25+ monitoring *.25+ well_being*.25+ non_contact_infrastructure*.25+ state_of_emergency+ `non-contact_school`+ prohibit_business+ prohibit_restaurants+ travel_screening+ prohibit_travel+ international_travel_quarantine+ gathering_size_limited+ mandatory_traveler_quarantine+ protect_high_risk_populations+ shelter_in_place)

# And write the csv of the time
write.csv(dfTS, "GA_county_intervention_time_series.csv")
