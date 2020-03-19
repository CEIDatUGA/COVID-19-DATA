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

dfTS <- data.frame(matrix(NA, nrow= length(levels(factor(df$NAME)))*length(dates), ncol = 7))

names(dfTS) <- c("NAME", "DATE", "prohibit_restaurants", "school_closure", "state_of_emergency", "prohibit_gatherings", "gathering_size")

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
  dfTS$school_closure[i] <- max(as.numeric("school_closure" %in% types), as.numeric("non-contact school" %in% types))
  dfTS$prohibit_gatherings[i] <- as.numeric("prohibit_gatherings" %in% types)
  dfTS$state_of_emergency[i] <- as.numeric("state of emergency" %in% types)
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
  states[[i]]$school_closure <- frontfill(states[[i]]$school_closure)
  states[[i]]$state_of_emergency <- frontfill(states[[i]]$state_of_emergency)
  states[[i]]$prohibit_gatherings <- frontfill(states[[i]]$prohibit_gatherings)
  states[[i]]$gathering_size <- frontfill(states[[i]]$gathering_size)
  
  
}


dfTS <- bind_rows(states)

dfTS <- dfTS %>%
  mutate(Intervention_Score = prohibit_restaurants+ school_closure+ state_of_emergency + prohibit_gatherings)


write.csv(dfTS, "../us-state-intervention-data/interventionTimeSeries.csv")
