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




write.csv(df, "../us-state-intervention-data/longFormStateInterventions.csv")

dates <- seq.Date(from = ymd("2020-02-01"), to = ymd(format(Sys.time(), '%Y-%m-%d')), by =1) 

dfTS <- data.frame(matrix(NA, nrow= length(levels(factor(df$NAME)))*length(dates), ncol = 12))

names(dfTS) <- c("NAME", "DATE", "mandatory_traveler_quarantine","prohibit_restaurants","prohibit_business", "non-contact_school", "state_of_emergency", "gathering_size_limited", "public_health_emergency", "shelter_in_place", "travel_screening","gathering_size")

dates <- seq.Date(from = ymd("2020-02-01"), to = ymd(format(Sys.time(), '%Y-%m-%d'))+1, by =1/length(levels(factor(df$NAME)))) 

for(i in 1:nrow(df)){
  if(is.na(df$start_date[i])){
    df$start_date[i] <- df$announcement_date[i]
  }
}

dfTS$NAME<- levels(factor(df$NAME))
dfTS$DATE <- as.character(dates[-1])


for(i in 1: nrow(dfTS)){
  types<- filter(df, NAME==dfTS$NAME[i], start_date == dfTS$DATE[i])$announcement_type
  dfTS$prohibit_restaurants[i] <- max(as.numeric("prohibit_restaurants" %in% types), as.numeric("prohibit restaurants" %in% types))
  dfTS$`non-contact_school`[i] <- max(as.numeric("school_closure" %in% types), as.numeric("non-contact school" %in% types))
  dfTS$gathering_size_limited[i] <- as.numeric("gathering_size_limited" %in% types)
  dfTS$state_of_emergency[i] <- as.numeric("state of emergency" %in% types)
  dfTS$mandatory_traveler_quarantine[i] <- as.numeric("mandatory_traveler_quarantine" %in% types)
  dfTS$prohibit_business[i] <- as.numeric("prohibit_business" %in% types)
  dfTS$public_health_emergency[i] <- as.numeric("public health emergency" %in% types)
  dfTS$shelter_in_place[i]<- as.numeric("shelter_in_place" %in% types)
  dfTS$travel_screening[i] <- as.numeric("travel_screening" %in% types)
  
  try(dfTS$gathering_size[i] <- filter(df, NAME==dfTS$NAME[i], start_date == dfTS$DATE[i])$gathering_size)
  
}


dfTS <- arrange(dfTS, NAME, DATE)

frontfill <- function(x){
  
  for(i in 2:length(x)){
    if(x[i]==0| is.na(x[i])){
      x[i]<- x[i-1]
    }
  }
  return(x)
}

states <- list()
for(i in 1: length(levels(factor(dfTS$NAME)))){
  states[[i]] <- filter(dfTS, NAME == levels(factor(dfTS$NAME))[i])
  states[[i]]$prohibit_restaurants <- frontfill(states[[i]]$prohibit_restaurants)
  states[[i]]$`non-contact_school` <- frontfill(states[[i]]$`non-contact_school`)
  states[[i]]$state_of_emergency <- frontfill(states[[i]]$state_of_emergency)
  states[[i]]$gathering_size_limited <- frontfill(states[[i]]$gathering_size_limited)
  states[[i]]$mandatory_traveler_quarantine <- frontfill(states[[i]]$mandatory_traveler_quarantine)
  states[[i]]$prohibit_business <- frontfill(states[[i]]$prohibit_business)
  states[[i]]$public_health_emergency <- frontfill(states[[i]]$public_health_emergency)
  states[[i]]$shelter_in_place <- frontfill(states[[i]]$shelter_in_place)
  states[[i]]$travel_screening <- frontfill(states[[i]]$travel_screening)
  states[[i]]$gathering_size <- frontfill(states[[i]]$gathering_size)
  
  
}


dfTS <- bind_rows(states)

dfTS <- dfTS %>%
  mutate(Intervention_Score = prohibit_restaurants+ `non-contact_school`+ state_of_emergency + gathering_size_limited + mandatory_traveler_quarantine+ prohibit_business + public_health_emergency + shelter_in_place+travel_screening)


write.csv(dfTS, "../us-state-intervention-data/interventionTimeSeries.csv")
