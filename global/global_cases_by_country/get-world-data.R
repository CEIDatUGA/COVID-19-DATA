


library(padr)
library(rvest)
library(tibbletime)
library(dplyr)
library(tidyr)
library(stringr)




df <- read.csv("worldCases.csv")%>%
  dplyr::select(Date, Country, Cases)

url <- "https://en.wikipedia.org/wiki/2019%E2%80%9320_coronavirus_pandemic_by_country_and_territory"
World.wikipedia <- url %>%
  html() %>%
  html_nodes(xpath='//*[@id="thetable"]') %>%
  html_table(fill = TRUE)
World.wikipedia <- World.wikipedia[[1]]
names(World.wikipedia) <- World.wikipedia[1,]
World.wikipedia <- World.wikipedia[2:(nrow(World.wikipedia)-2),2:3]
names(World.wikipedia)<- c("Country", "Cases")
for(i in 1: nrow(World.wikipedia)){
  if(str_sub(World.wikipedia$Country[i], start= -1, end = -1)=="]"){
    World.wikipedia$Country[i] <- str_sub(World.wikipedia$Country[i], start = 1, end = -4)
  }
}

World.wikipedia$Date <- format(Sys.time(), '%Y-%m-%d')
# Then strip out the extraneous columns)


World.wikipedia$Cases <- as.numeric(as.character(gsub(",","" , World.wikipedia$Cases)))

World.wikipedia$Country <- replace(World.wikipedia$Country, which(World.wikipedia$Country=="Netherlands[l]"), "Netherlands")

World.wikipedia$Country <- replace(World.wikipedia$Country, which(World.wikipedia$Country=="United States[f]"), "United States")

World.wikipedia$Country <- replace(World.wikipedia$Country, which(World.wikipedia$Country=="Denmark[p][q]"), "Denmark")

World.wikipedia$Country <- replace(World.wikipedia$Country, which(World.wikipedia$Country=="MS Zaandam["), "MS Zaandam")

World.wikipedia$Country <- replace(World.wikipedia$Country, which(World.wikipedia$Country=="Somalia ["), "Somalia")
World.wikipedia$Country <- replace(World.wikipedia$Country, which(World.wikipedia$Country=="Somalia["), "Somalia")

World.wikipedia$Country <- replace(World.wikipedia$Country, which(World.wikipedia$Country=="MS Zaandam & Rotterdam["), "MS Zaandam & Rotterdam")

World.wikipedia$Country <- replace(World.wikipedia$Country, which(World.wikipedia$Country=="Kosovo["), "Kosovo")

World.wikipedia$Country <- replace(World.wikipedia$Country, which(World.wikipedia$Country=="Georgia["), "Georgia")

World.wikipedia$Country <- replace(World.wikipedia$Country, which(World.wikipedia$Country=="French Guiana["), "French Guiana")

dfNew <- bind_rows(df, World.wikipedia) %>% dplyr::select(Date, Country, Cases) 

for(i in 1:nrow(dfNew)){
  
  if(str_sub(dfNew$Country[i], start=-1)=="["){
    dfNew$Country[i] <- str_sub(dfNew$Country[i], end =-2)
  }
}

write.csv(dfNew, "worldCases.csv")
