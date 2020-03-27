### This script reads the human scraped data on state interventions
### Originated by: Robbie Richards
### Originated on: 3/18/2020


library(tidyr)
library(dplyr)
library(googledrive)
library(googlesheets4)
library(lubridate)

options(gargle_oauth_email = "robbielrichards@gmail.com")
df <- read_sheet("https://docs.google.com/spreadsheets/d/1_mk1J3ElMH5EmPILcrx8s1KqHqdQYXCWroJeKTR3pV4/edit#gid=221668309", range = "state-covid-announcements")
  


df <- df %>%  
  mutate(start_date = ymd(as.character(start_date)))




write.csv(df, "US_raw_state_interventions.csv")

dates <- seq.Date(from = ymd("2020-02-01"), to = ymd(format(Sys.time(), '%Y-%m-%d')), by =1) 

dfTS <- data.frame(matrix(0, nrow= length(levels(factor(df$NAME)))*length(dates), ncol = 23))

names(dfTS) <- c("NAME", "DATE", "mandatory_traveler_quarantine","prohibit_restaurants","prohibit_business", "non-contact_school", "state_of_emergency", "gathering_size_limited", "public_health_emergency", "shelter_in_place", "travel_screening","close_public_spaces", "social_distancing","gathering_size", "monitoring", "well_being", "animal_distancing", "non_contact_infrastructure", "prohibit_travel", "international_travel_quarantine", "protect_high_risk_populations", "personal_hygiene", "environmental_hygiene")

dates <- seq.Date(from = ymd("2020-02-01"), to = ymd(format(Sys.time(), '%Y-%m-%d'))+1, by =1/length(levels(factor(df$NAME)))) 

for(i in 1:nrow(df)){
  if(is.na(df$start_date[i])){
    df$start_date[i] <- df$announcement_date[i]
  }
}
dfTS$NAME<- levels(factor(df$NAME))
dfTS$DATE <- as.character(dates[-1])
df <- df %>% filter(!is.na(start_date))



dfTS$gathering_size <- NA

states <- list()
for(i in 1: length(levels(factor(dfTS$NAME)))){
  states[[i]] <- filter(dfTS, NAME == levels(factor(dfTS$NAME))[i]) %>%
    mutate(DATE = ymd(DATE))
  stateAnnouncements <- filter(df,NAME ==  levels(factor(dfTS$NAME))[i])
  #prohibit_restaurants
  subAnnouncements <- filter(stateAnnouncements, announcement_type == "prohibit_restaurants")
  if(nrow(subAnnouncements)>0){
    for(j in 1:nrow(subAnnouncements)){
      if(is.na(subAnnouncements$end_date[j]) & nrow(subAnnouncements)==1){subAnnouncements$end_date[j] <- ymd(format(Sys.time(), '%Y-%m-%d'))+1}
      # This anticipates all future records being entered with a valid start date and not just as an end date
      # But it also will allow us to more easily deal with on and off measures I think
      if(is.na(subAnnouncements$end_date[j]) & nrow(subAnnouncements)>1){subAnnouncements$end_date[j] <- max(subAnnouncements$start_date, na.rm=T)}
      # This just catches if all the other end_dates were also NA and fills in today as end date
      if(is.na(subAnnouncements$end_date[j])|is.infinite(subAnnouncements$end_date[j])){subAnnouncements$end_date[j] <- ymd(format(Sys.time(), '%Y-%m-%d'))+1}
      announceInterval <- lubridate::interval(subAnnouncements$start_date[j], subAnnouncements$end_date[j])
      inside <- which(states[[i]]$DATE %within% announceInterval)
      states[[i]]$prohibit_restaurants[inside] <- 1
    }
  }
  #non-contact_school
  subAnnouncements <- filter(stateAnnouncements, announcement_type == "no_contact_school"|announcement_type =="non-contact school")
  if(nrow(subAnnouncements)>0){
    for(j in 1:nrow(subAnnouncements)){
      if(is.na(subAnnouncements$end_date[j]) & nrow(subAnnouncements)==1){subAnnouncements$end_date[j] <- ymd(format(Sys.time(), '%Y-%m-%d'))+1}
      # This anticipates all future records being entered with a valid start date and not just as an end date
      # But it also will allow us to more easily deal with on and off measures I think
      if(is.na(subAnnouncements$end_date[j]) & nrow(subAnnouncements)>1){subAnnouncements$end_date[j] <- max(subAnnouncements$start_date, na.rm=T)}
      # This just catches if all the other end_dates were also NA and fills in today as end date
      if(is.na(subAnnouncements$end_date[j])|is.infinite(subAnnouncements$end_date[j])){subAnnouncements$end_date[j] <- ymd(format(Sys.time(), '%Y-%m-%d'))+1}
      announceInterval <- lubridate::interval(subAnnouncements$start_date[j], subAnnouncements$end_date[j])
      inside <- which(states[[i]]$DATE %within% announceInterval)
      states[[i]]$`non-contact_school`[inside] <- 1
    }
  }
  #environmental_hygiene
  subAnnouncements <- filter(stateAnnouncements, announcement_type == "environmental_hygiene")
  if(nrow(subAnnouncements)>0){
    for(j in 1:nrow(subAnnouncements)){
      if(is.na(subAnnouncements$end_date[j]) & nrow(subAnnouncements)==1){subAnnouncements$end_date[j] <- ymd(format(Sys.time(), '%Y-%m-%d'))+1}
      # This anticipates all future records being entered with a valid start date and not just as an end date
      # But it also will allow us to more easily deal with on and off measures I think
      if(is.na(subAnnouncements$end_date[j]) & nrow(subAnnouncements)>1){subAnnouncements$end_date[j] <- max(subAnnouncements$start_date, na.rm=T)}
      # This just catches if all the other end_dates were also NA and fills in today as end date
      if(is.na(subAnnouncements$end_date[j])|is.infinite(subAnnouncements$end_date[j])){subAnnouncements$end_date[j] <- ymd(format(Sys.time(), '%Y-%m-%d'))+1}
      announceInterval <- lubridate::interval(subAnnouncements$start_date[j], subAnnouncements$end_date[j])
      inside <- which(states[[i]]$DATE %within% announceInterval)
      states[[i]]$environmental_hygiene[inside] <- 1
    }
  }
  #close_public_spaces
  subAnnouncements <- filter(stateAnnouncements, announcement_type == "close_public spaces"|announcement_type =="close_public_spaces")
  if(nrow(subAnnouncements)>0){
    for(j in 1:nrow(subAnnouncements)){
      if(is.na(subAnnouncements$end_date[j]) & nrow(subAnnouncements)==1){subAnnouncements$end_date[j] <- ymd(format(Sys.time(), '%Y-%m-%d'))+1}
      # This anticipates all future records being entered with a valid start date and not just as an end date
      # But it also will allow us to more easily deal with on and off measures I think
      if(is.na(subAnnouncements$end_date[j]) & nrow(subAnnouncements)>1){subAnnouncements$end_date[j] <- max(subAnnouncements$start_date, na.rm=T)}
      # This just catches if all the other end_dates were also NA and fills in today as end date
      if(is.na(subAnnouncements$end_date[j])|is.infinite(subAnnouncements$end_date[j])){subAnnouncements$end_date[j] <- ymd(format(Sys.time(), '%Y-%m-%d'))+1}
      announceInterval <- lubridate::interval(subAnnouncements$start_date[j], subAnnouncements$end_date[j])
      inside <- which(states[[i]]$DATE %within% announceInterval)
      states[[i]]$close_public_spaces[inside] <- 1
    }
  }
  #gathering_size_limited
  subAnnouncements <- filter(stateAnnouncements, announcement_type == "gathering_size_limited")
  if(nrow(subAnnouncements)>0){
    for(j in 1:nrow(subAnnouncements)){
      if(is.na(subAnnouncements$end_date[j]) & nrow(subAnnouncements)==1){subAnnouncements$end_date[j] <- ymd(format(Sys.time(), '%Y-%m-%d'))+1}
      # This anticipates all future records being entered with a valid start date and not just as an end date
      # But it also will allow us to more easily deal with on and off measures I think
      if(is.na(subAnnouncements$end_date[j]) & nrow(subAnnouncements)>1){subAnnouncements$end_date[j] <- max(subAnnouncements$start_date, na.rm=T)}
      # This just catches if all the other end_dates were also NA and fills in today as end date
      if(is.na(subAnnouncements$end_date[j])|is.infinite(subAnnouncements$end_date[j])){subAnnouncements$end_date[j] <- ymd(format(Sys.time(), '%Y-%m-%d'))+1}
      announceInterval <- lubridate::interval(subAnnouncements$start_date[j], subAnnouncements$end_date[j])
      inside <- which(states[[i]]$DATE %within% announceInterval)
      states[[i]]$gathering_size_limited[inside] <- 1
      states[[i]]$gathering_size[inside] <-subAnnouncements$gathering_size[j]
    }
  }
  
  #personal_hygiene
  subAnnouncements <- filter(stateAnnouncements, announcement_type == "personal_hygiene")
  if(nrow(subAnnouncements)>0){
    for(j in 1:nrow(subAnnouncements)){
      if(is.na(subAnnouncements$end_date[j]) & nrow(subAnnouncements)==1){subAnnouncements$end_date[j] <- ymd(format(Sys.time(), '%Y-%m-%d'))+1}
      # This anticipates all future records being entered with a valid start date and not just as an end date
      # But it also will allow us to more easily deal with on and off measures I think
      if(is.na(subAnnouncements$end_date[j]) & nrow(subAnnouncements)>1){subAnnouncements$end_date[j] <- max(subAnnouncements$start_date, na.rm=T)}
      # This just catches if all the other end_dates were also NA and fills in today as end date
      if(is.na(subAnnouncements$end_date[j])|is.infinite(subAnnouncements$end_date[j])){subAnnouncements$end_date[j] <- ymd(format(Sys.time(), '%Y-%m-%d'))+1}
      announceInterval <- lubridate::interval(subAnnouncements$start_date[j], subAnnouncements$end_date[j])
      inside <- which(states[[i]]$DATE %within% announceInterval)
      states[[i]]$personal_hygiene[inside] <- 1
    }
  }
  #prohibit_business
  subAnnouncements <- filter(stateAnnouncements, announcement_type == "prohibit_business")
  if(nrow(subAnnouncements)>0){
    for(j in 1:nrow(subAnnouncements)){
      if(is.na(subAnnouncements$end_date[j]) & nrow(subAnnouncements)==1){subAnnouncements$end_date[j] <- ymd(format(Sys.time(), '%Y-%m-%d'))+1}
      # This anticipates all future records being entered with a valid start date and not just as an end date
      # But it also will allow us to more easily deal with on and off measures I think
      if(is.na(subAnnouncements$end_date[j]) & nrow(subAnnouncements)>1){subAnnouncements$end_date[j] <- max(subAnnouncements$start_date, na.rm=T)}
      # This just catches if all the other end_dates were also NA and fills in today as end date
      if(is.na(subAnnouncements$end_date[j])|is.infinite(subAnnouncements$end_date[j])){subAnnouncements$end_date[j] <- ymd(format(Sys.time(), '%Y-%m-%d'))+1}
      announceInterval <- lubridate::interval(subAnnouncements$start_date[j], subAnnouncements$end_date[j])
      inside <- which(states[[i]]$DATE %within% announceInterval)
      states[[i]]$prohibit_business[inside] <- 1
    }
  }
  #shelter_in_place
  subAnnouncements <- filter(stateAnnouncements, announcement_type == "shelter_in_place")
  if(nrow(subAnnouncements)>0){
    for(j in 1:nrow(subAnnouncements)){
      if(is.na(subAnnouncements$end_date[j]) & nrow(subAnnouncements)==1){subAnnouncements$end_date[j] <- ymd(format(Sys.time(), '%Y-%m-%d'))+1}
      # This anticipates all future records being entered with a valid start date and not just as an end date
      # But it also will allow us to more easily deal with on and off measures I think
      if(is.na(subAnnouncements$end_date[j]) & nrow(subAnnouncements)>1){subAnnouncements$end_date[j] <- max(subAnnouncements$start_date, na.rm=T)}
      # This just catches if all the other end_dates were also NA and fills in today as end date
      if(is.na(subAnnouncements$end_date[j])|is.infinite(subAnnouncements$end_date[j])){subAnnouncements$end_date[j] <- ymd(format(Sys.time(), '%Y-%m-%d'))+1}
      announceInterval <- lubridate::interval(subAnnouncements$start_date[j], subAnnouncements$end_date[j])
      inside <- which(states[[i]]$DATE %within% announceInterval)
      states[[i]]$shelter_in_place[inside] <- 1
    }
  }
  #social_distancing
  subAnnouncements <- filter(stateAnnouncements, announcement_type == "social_distancing")
  if(nrow(subAnnouncements)>0){
    for(j in 1:nrow(subAnnouncements)){
      if(is.na(subAnnouncements$end_date[j]) & nrow(subAnnouncements)==1){subAnnouncements$end_date[j] <- ymd(format(Sys.time(), '%Y-%m-%d'))+1}
      # This anticipates all future records being entered with a valid start date and not just as an end date
      # But it also will allow us to more easily deal with on and off measures I think
      if(is.na(subAnnouncements$end_date[j]) & nrow(subAnnouncements)>1){subAnnouncements$end_date[j] <- max(subAnnouncements$start_date, na.rm=T)}
      # This just catches if all the other end_dates were also NA and fills in today as end date
      if(is.na(subAnnouncements$end_date[j])|is.infinite(subAnnouncements$end_date[j])){subAnnouncements$end_date[j] <- ymd(format(Sys.time(), '%Y-%m-%d'))+1}
      announceInterval <- lubridate::interval(subAnnouncements$start_date[j], subAnnouncements$end_date[j])
      inside <- which(states[[i]]$DATE %within% announceInterval)
      states[[i]]$social_distancing[inside] <- 1
    }
  }
  #state_of_emergency
  subAnnouncements <- filter(stateAnnouncements, announcement_type == "state_of_emergency"|announcement_type == "state of emergency")
  if(nrow(subAnnouncements)>0){
    for(j in 1:nrow(subAnnouncements)){
      if(is.na(subAnnouncements$end_date[j]) & nrow(subAnnouncements)==1){subAnnouncements$end_date[j] <- ymd(format(Sys.time(), '%Y-%m-%d'))+1}
      # This anticipates all future records being entered with a valid start date and not just as an end date
      # But it also will allow us to more easily deal with on and off measures I think
      if(is.na(subAnnouncements$end_date[j]) & nrow(subAnnouncements)>1){subAnnouncements$end_date[j] <- max(subAnnouncements$start_date, na.rm=T)}
      # This just catches if all the other end_dates were also NA and fills in today as end date
      if(is.na(subAnnouncements$end_date[j])|is.infinite(subAnnouncements$end_date[j])){subAnnouncements$end_date[j] <- ymd(format(Sys.time(), '%Y-%m-%d'))+1}
      announceInterval <- lubridate::interval(subAnnouncements$start_date[j], subAnnouncements$end_date[j])
      inside <- which(states[[i]]$DATE %within% announceInterval)
      states[[i]]$state_of_emergency[inside] <- 1
    }
  }
  #monitoring
  subAnnouncements <- filter(stateAnnouncements, announcement_type == "monitoring")
  if(nrow(subAnnouncements)>0){
    for(j in 1:nrow(subAnnouncements)){
      if(is.na(subAnnouncements$end_date[j]) & nrow(subAnnouncements)==1){subAnnouncements$end_date[j] <- ymd(format(Sys.time(), '%Y-%m-%d'))+1}
      # This anticipates all future records being entered with a valid start date and not just as an end date
      # But it also will allow us to more easily deal with on and off measures I think
      if(is.na(subAnnouncements$end_date[j]) & nrow(subAnnouncements)>1){subAnnouncements$end_date[j] <- max(subAnnouncements$start_date, na.rm=T)}
      # This just catches if all the other end_dates were also NA and fills in today as end date
      if(is.na(subAnnouncements$end_date[j])|is.infinite(subAnnouncements$end_date[j])){subAnnouncements$end_date[j] <- ymd(format(Sys.time(), '%Y-%m-%d'))+1}
      announceInterval <- lubridate::interval(subAnnouncements$start_date[j], subAnnouncements$end_date[j])
      inside <- which(states[[i]]$DATE %within% announceInterval)
      states[[i]]$monitoring[inside] <- 1
    }
  }
  #well_being
  subAnnouncements <- filter(stateAnnouncements, announcement_type == "well_being")
  if(nrow(subAnnouncements)>0){
    for(j in 1:nrow(subAnnouncements)){
      if(is.na(subAnnouncements$end_date[j]) & nrow(subAnnouncements)==1){subAnnouncements$end_date[j] <- ymd(format(Sys.time(), '%Y-%m-%d'))+1}
      # This anticipates all future records being entered with a valid start date and not just as an end date
      # But it also will allow us to more easily deal with on and off measures I think
      if(is.na(subAnnouncements$end_date[j]) & nrow(subAnnouncements)>1){subAnnouncements$end_date[j] <- max(subAnnouncements$start_date, na.rm=T)}
      # This just catches if all the other end_dates were also NA and fills in today as end date
      if(is.na(subAnnouncements$end_date[j])|is.infinite(subAnnouncements$end_date[j])){subAnnouncements$end_date[j] <- ymd(format(Sys.time(), '%Y-%m-%d'))+1}
      announceInterval <- lubridate::interval(subAnnouncements$start_date[j], subAnnouncements$end_date[j])
      inside <- which(states[[i]]$DATE %within% announceInterval)
      states[[i]]$well_being[inside] <- 1
    }
  }
  #animal_distancing
  subAnnouncements <- filter(stateAnnouncements, announcement_type == "animal_distancing")
  if(nrow(subAnnouncements)>0){
    for(j in 1:nrow(subAnnouncements)){
      if(is.na(subAnnouncements$end_date[j]) & nrow(subAnnouncements)==1){subAnnouncements$end_date[j] <- ymd(format(Sys.time(), '%Y-%m-%d'))+1}
      # This anticipates all future records being entered with a valid start date and not just as an end date
      # But it also will allow us to more easily deal with on and off measures I think
      if(is.na(subAnnouncements$end_date[j]) & nrow(subAnnouncements)>1){subAnnouncements$end_date[j] <- max(subAnnouncements$start_date, na.rm=T)}
      # This just catches if all the other end_dates were also NA and fills in today as end date
      if(is.na(subAnnouncements$end_date[j])|is.infinite(subAnnouncements$end_date[j])){subAnnouncements$end_date[j] <- ymd(format(Sys.time(), '%Y-%m-%d'))+1}
      announceInterval <- lubridate::interval(subAnnouncements$start_date[j], subAnnouncements$end_date[j])
      inside <- which(states[[i]]$DATE %within% announceInterval)
      states[[i]]$animal_distancing[inside] <- 1
    }
  }
  #non_contact_infrastructure
  subAnnouncements <- filter(stateAnnouncements, announcement_type == "non_contact_infrastructure")
  if(nrow(subAnnouncements)>0){
    for(j in 1:nrow(subAnnouncements)){
      if(is.na(subAnnouncements$end_date[j]) & nrow(subAnnouncements)==1){subAnnouncements$end_date[j] <- ymd(format(Sys.time(), '%Y-%m-%d'))+1}
      # This anticipates all future records being entered with a valid start date and not just as an end date
      # But it also will allow us to more easily deal with on and off measures I think
      if(is.na(subAnnouncements$end_date[j]) & nrow(subAnnouncements)>1){subAnnouncements$end_date[j] <- max(subAnnouncements$start_date, na.rm=T)}
      # This just catches if all the other end_dates were also NA and fills in today as end date
      if(is.na(subAnnouncements$end_date[j])|is.infinite(subAnnouncements$end_date[j])){subAnnouncements$end_date[j] <- ymd(format(Sys.time(), '%Y-%m-%d'))+1}
      announceInterval <- lubridate::interval(subAnnouncements$start_date[j], subAnnouncements$end_date[j])
      inside <- which(states[[i]]$DATE %within% announceInterval)
      states[[i]]$non_contact_infrastructure[inside] <- 1
    }
  }
  #prohibit_travel
  subAnnouncements <- filter(stateAnnouncements, announcement_type == "prohibit_travel")
  if(nrow(subAnnouncements)>0){
    for(j in 1:nrow(subAnnouncements)){
      if(is.na(subAnnouncements$end_date[j]) & nrow(subAnnouncements)==1){subAnnouncements$end_date[j] <- ymd(format(Sys.time(), '%Y-%m-%d'))+1}
      # This anticipates all future records being entered with a valid start date and not just as an end date
      # But it also will allow us to more easily deal with on and off measures I think
      if(is.na(subAnnouncements$end_date[j]) & nrow(subAnnouncements)>1){subAnnouncements$end_date[j] <- max(subAnnouncements$start_date, na.rm=T)}
      # This just catches if all the other end_dates were also NA and fills in today as end date
      if(is.na(subAnnouncements$end_date[j])|is.infinite(subAnnouncements$end_date[j])){subAnnouncements$end_date[j] <- ymd(format(Sys.time(), '%Y-%m-%d'))+1}
      announceInterval <- lubridate::interval(subAnnouncements$start_date[j], subAnnouncements$end_date[j])
      inside <- which(states[[i]]$DATE %within% announceInterval)
      states[[i]]$prohibit_travel[inside] <- 1
    }
  }
  #international_travel_quarantine
  subAnnouncements <- filter(stateAnnouncements, announcement_type == "international_travel_quarantine")
  if(nrow(subAnnouncements)>0){
    for(j in 1:nrow(subAnnouncements)){
      if(is.na(subAnnouncements$end_date[j]) & nrow(subAnnouncements)==1){subAnnouncements$end_date[j] <- ymd(format(Sys.time(), '%Y-%m-%d'))+1}
      # This anticipates all future records being entered with a valid start date and not just as an end date
      # But it also will allow us to more easily deal with on and off measures I think
      if(is.na(subAnnouncements$end_date[j]) & nrow(subAnnouncements)>1){subAnnouncements$end_date[j] <- max(subAnnouncements$start_date, na.rm=T)}
      # This just catches if all the other end_dates were also NA and fills in today as end date
      if(is.na(subAnnouncements$end_date[j])|is.infinite(subAnnouncements$end_date[j])){subAnnouncements$end_date[j] <- ymd(format(Sys.time(), '%Y-%m-%d'))+1}
      announceInterval <- lubridate::interval(subAnnouncements$start_date[j], subAnnouncements$end_date[j])
      inside <- which(states[[i]]$DATE %within% announceInterval)
      states[[i]]$international_travel_quarantine[inside] <- 1
    }
  }
  #protect_high_risk_populations
  subAnnouncements <- filter(stateAnnouncements, announcement_type == "protect_high_risk_populations")
  if(nrow(subAnnouncements)>0){
    for(j in 1:nrow(subAnnouncements)){
      if(is.na(subAnnouncements$end_date[j]) & nrow(subAnnouncements)==1){subAnnouncements$end_date[j] <- ymd(format(Sys.time(), '%Y-%m-%d'))+1}
      # This anticipates all future records being entered with a valid start date and not just as an end date
      # But it also will allow us to more easily deal with on and off measures I think
      if(is.na(subAnnouncements$end_date[j]) & nrow(subAnnouncements)>1){subAnnouncements$end_date[j] <- max(subAnnouncements$start_date, na.rm=T)}
      # This just catches if all the other end_dates were also NA and fills in today as end date
      if(is.na(subAnnouncements$end_date[j])|is.infinite(subAnnouncements$end_date[j])){subAnnouncements$end_date[j] <- ymd(format(Sys.time(), '%Y-%m-%d'))+1}
      announceInterval <- lubridate::interval(subAnnouncements$start_date[j], subAnnouncements$end_date[j])
      inside <- which(states[[i]]$DATE %within% announceInterval)
      states[[i]]$protect_high_risk_populations[inside] <- 1
    }
  }
}


dfTS <- bind_rows(states)

dfTS <- dfTS %>%
  mutate(Intervention_Score = social_distancing*.25+ close_public_spaces+ personal_hygiene*.25+ environmental_hygiene*.25+ monitoring *.25+ well_being*.25+ non_contact_infrastructure*.25+ state_of_emergency+ `non-contact_school`+ prohibit_business+ prohibit_restaurants+ travel_screening+ prohibit_travel+ international_travel_quarantine+ gathering_size_limited+ mandatory_traveler_quarantine+ protect_high_risk_populations+ shelter_in_place)


write.csv(dfTS, "US_state_intervention_time_series.csv")
