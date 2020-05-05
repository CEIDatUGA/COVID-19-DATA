# set up libraries
library(httr)
library(xml2)
library(rvest)
library(dplyr)
library(tidyr)
library(stringr)
library(magrittr)
library(here)

# set sub directory
setwd(here("china","China_casedata")) 
  
# save html 
url = "https://ncov.dxy.cn/ncovh5/view/pneumonia"
get_object = GET(url)
cat(content(get_object, "text"), file="temp.html")
html_object = read_html(url)
write_xml(html_object, file=paste("dxy-html-archive/",
                                  str_sub(get_object$headers$date, 6, 7),
                                  toupper(str_sub(get_object$headers$date, 9, 11)),
                                  str_sub(get_object$headers$date, 18, 19),
                                  str_sub(get_object$headers$date, 21, 22),
                                  ".html",sep = "")) 

# list out all file names and dates
fileNames <- list.files(path = "dxy-html-archive", pattern = "*.html", full.names = F) # read all files in 
fileNames <- str_sub(fileNames, end = 9) # remove excess part of file

# loop through for all files 
for(fileName in fileNames){ 
# pull from archived html site
rawHTML <- paste(readLines(paste("dxy-html-archive/", fileName,".html",  sep = "")), collapse="\n")
webpage <- read_html(rawHTML) #pull text from webpage
text <- webpage %>% html_nodes("body") %>% html_text() # extract all text from body
# remove beginning text "
clean_text <- substring(text, 29) 
# remove ending text 
clean_text<-str_sub(clean_text, end=-162) 
clean_text<- gsub('"', '', clean_text) # remove quotes

# split character string by province 
split1 <- strsplit(clean_text, split = "\\{") # split by open bracket

# trying to reshape data
test <- as.data.frame(split1) # convert to data table 
names(test)[1]<-"text" # rename column
# only include for cities or provinces 
test <- dplyr::filter(test, grepl('province|city',text))
test <- separate(test, text, sep = ",", 
                 into = c("v1", "v2", "v3","v4", "v5", "v6", "v7", "v8", "v9", "v10", "v11", "v12", "v13", "v14", "v15", "v16", "v17"), 
                 extra = "merge")
# gather to unique province name 
test <- test %>% gather("n_variable", "variable", -v1)
# separate out variable 
test <- separate(test, variable, sep = ":", 
              into = c("variable", "value"),
              extra = "merge")
test$n_variable <- NULL # remove arbitrary numbered columns numbers from earlier
# remove unneccessary variables (cities, NA)
test <- dplyr::filter(test, variable != "cities")
test <- dplyr::filter(test, variable != "")
test <- dplyr::filter(test, v1 != "")
test <- dplyr::filter(test, grepl('province|city',v1))

# if error due to duplicate variables...
test$province <- ifelse(str_extract(test$v1, "^.{1}") == "p", test$v1, NA)
test %<>% fill(province)
test$province <- str_sub(test$province, start = 14) # remove provinceName:

# spread variable to columns 
test <- test %>% spread(variable, value)
test <- separate(test, v1, sep = ":", 
                 into = c("area_type", "area_name"),
                 extra = "merge")
test <- dplyr::filter(test, area_type != "id") # remove other html tables
test <- dplyr::filter(test, area_type != "countryType") # remove other html tables

# later dates have certain columns, make sure to add to early html versions 
new_cols <- data.frame("currentConfirmedCount" = rep(NA, nrow(test)))
test <- bind_cols(test, new_cols) # adds new column. if this already exists, as as "currentConfirmedCount1"
# remove empty columns 
test <- dplyr::select(test, province, area_type, area_name, confirmedCount, currentConfirmedCount, suspectedCount, deadCount, curedCount, comment)
test$area_type <- str_sub(test$area_type, end = -5)

# keep only digits in deadCount column 
test$deadCount <- str_extract(test$deadCount , "\\-*\\d+\\.*\\d*")

# save raw file with date in name 
write.csv(test, file = paste("dxy_data/clean-daily-tables/dxy_", str_sub(fileName, 1, 5), "2020.csv", sep ="")) 
} 

# load adm file
cn_adm2 <- read.csv(file = "dxy_data/spatial/shapefile_adm2_modified.csv")
# transform adm spatial look up table
adm_match_area <- cn_adm2 %>% 
  dplyr::select(ADM0_EN, ADM1_EN, ADM2_EN, ADM3_EN, # english names 
                ADM1_ZH,ADM2_ZH, ADM2_ZH_short, ADM3_ZH, ADM3_ZH_short) %>% # chinese names
  unique() 
# save unique prefecture-province pairs for master file later
prefecture_adm <- adm_match_area %>% 
  dplyr::select(ADM0_EN, ADM1_EN, ADM2_EN) %>% unique()
write.csv(prefecture_adm, file = "dxy_data/spatial/prefecture_adm.csv") 
province_adm <- prefecture_adm %>% 
  dplyr::select(ADM0_EN, ADM1_EN) %>% unique()
write.csv(province_adm, file = "dxy_data/spatial/province_adm.csv")

cleanTables <- str_sub(fileNames, end = 5) # modify file names slightly to just day-month
for(cleanTable in cleanTables){
test <- read.csv(file = paste("dxy_data/clean-daily-tables/dxy_", cleanTable, "2020.csv", sep= "")) 
# merge in adm info 
test$ADM_level <- ifelse(test$area_name %in% cn_adm2$ADM1_ZH |
                         test$area_name %in% cn_adm2$ADM1_ZH_short, "ADM1",
                  ifelse(test$area_name %in% cn_adm2$ADM2_ZH | 
                         test$area_name %in% cn_adm2$ADM2_ZH_short, "ADM2", 
                  ifelse(test$area_name %in% cn_adm2$ADM3_ZH | 
                         test$area_name %in% cn_adm2$ADM3_ZH_short, "ADM3", "unknown")))
test$name_variable <- ifelse(test$area_name %in% cn_adm2$ADM2_ZH, "ADM2_ZH",
                      ifelse(test$area_name %in% cn_adm2$ADM2_ZH_short, "ADM2_ZH_short", 
                      ifelse(test$area_name %in% cn_adm2$ADM1_ZH, "ADM1_ZH", 
                      ifelse(test$area_name %in% cn_adm2$ADM1_ZH_short, "ADM1_ZH_short",       
                      ifelse(test$area_name %in% cn_adm2$ADM3_ZH, "ADM3_ZH", 
                      ifelse(test$area_name %in% cn_adm2$ADM3_ZH_short, "ADM3_ZH_short","unknown"))))))
test$province_variable <- ifelse(test$province %in% cn_adm2$ADM1_ZH, "ADM1_ZH",
                          ifelse(test$area_name %in% cn_adm2$ADM1_ZH_short, "ADM1_ZH_short", "unknown"))
# create match table 
adm_match_along <- gather(adm_match_area, name_variable, area_name, ADM1_ZH:ADM3_ZH_short, factor_key = TRUE)
adm_match_along <- dplyr::filter(adm_match_along, area_name != "") %>% unique()

# merge in province names and province variable 
adm_match_province <- cn_adm2 %>% 
  select(ADM0_EN, ADM1_EN, ADM1_ZH, ADM1_ZH_short) %>% unique()
adm_match_plong <- gather(adm_match_province, province_variable, province, ADM1_ZH:ADM1_ZH_short, factor_key = TRUE)
adm_match <- left_join(adm_match_along, adm_match_plong, by = c("ADM0_EN", "ADM1_EN")) %>% unique()

test_adm1 <- dplyr::filter(test, area_type == "province")
test_adm1 <- left_join(test_adm1, adm_match, by = c("area_name", "name_variable", "province", "province_variable")) %>% unique()
province <- test_adm1 %>% select(ADM0_EN, ADM1_EN, confirmedCount, currentConfirmedCount, suspectedCount, deadCount, curedCount)
province$DATE <- paste("2020-", cleanTable,  sep = "")
province_master <- read.csv("dxy_data/spatial/province_adm.csv")
province_master$X <- NULL
province_cases <- full_join(province_master, province, by =c("ADM0_EN","ADM1_EN"))
#province_master <- rbind(province_master, province) %>% unique()
province_cases <- province_cases %>% fill(DATE) # fill date 
province_cases$confirmedCount <- ifelse(is.na(province_cases$confirmedCount) == T, 0, province_cases$confirmedCount) # add 0s
province_cases$currentConfirmedCount <- ifelse(is.na(province_cases$currentConfirmedCount) == T, 0, province_cases$currentConfirmedCount) # add 0s
province_cases$deadCount <- ifelse(is.na(province_cases$deadCount) == T, 0, province_cases$deadCount)
province_cases$suspectedCount <- ifelse(is.na(province_cases$suspectedCount) == T, 0, province_cases$suspectedCount)
province_cases$curedCount <- ifelse(is.na(province_cases$curedCount) == T, 0, province_cases$curedCount)
province_cases <- unique(province_cases)
write.csv(province_cases, file = paste("dxy_data/clean-daily-tables/adm-verified/province/", cleanTable, "2020.csv", sep = ""))

test_adm2 <- dplyr::filter(test, area_type != "province")
test_adm2 <- left_join(test_adm2, adm_match, by = c("area_name", "name_variable", "province", "province_variable")) %>% unique()
prefecture <- test_adm2 %>% 
  group_by(ADM0_EN, ADM1_EN, ADM2_EN) %>% #this groups by province-prefecture pairs 
  summarise(confirmedCount = sum(as.numeric(confirmedCount)),
            currentConfirmedCount = sum(as.numeric(currentConfirmedCount)), 
            suspectedCount = sum(as.numeric(suspectedCount)),
            deadCount = sum(as.numeric(deadCount)),
            curedCount = sum(as.numeric(curedCount)))
# add date 
prefecture$DATE <-paste("2020-", cleanTable, sep = "")
prefect_master <- read.csv(file = "dxy_data/spatial/prefecture_adm.csv") # load master spatial taxonomy 
master_case<- full_join(prefect_master, prefecture, by = c("ADM0_EN", "ADM1_EN", "ADM2_EN")) # merge column 
master_case <- master_case %>% fill(DATE) %>% fill(DATE, .direction = "up")
master_case$confirmedCount <- ifelse(is.na(master_case$confirmedCount) == T, 0, master_case$confirmedCount) # add 0s
master_case$currentConfirmedCount <- ifelse(is.na(master_case$currentConfirmedCount) == T, 0, master_case$currentConfirmedCount) # add 0s
master_case$deadCount <- ifelse(is.na(master_case$deadCount) == T, 0, master_case$deadCount)
master_case$suspectedCount <- ifelse(is.na(master_case$suspectedCount) == T, 0, master_case$suspectedCount)
master_case$curedCount <- ifelse(is.na(master_case$curedCount) == T, 0, master_case$curedCount) # add 0s
write.csv(master_case, file = paste("dxy_data/clean-daily-tables/adm-verified/prefecture/",cleanTable, "2020.csv", sep = ""))
}

province_cleanNames <- list.files(path = "dxy_data/clean-daily-tables/adm-verified/province", pattern = "*.csv", full.names = T)
master_province <- data.frame() # empty data frame 
# merge all province data 
for (province_cleanName in province_cleanNames){
  daily_data <- read.csv(province_cleanName) #each file will be read in, specify which columns you need read in to avoid any errors
  daily_data$X <- NULL
  daily_data$X.1 <- NULL
  master_province <- rbind(master_province, daily_data) #for each iteration, bind the new data to the building dataset
}
master_province <- unique(master_province)
master_province$DATE <- ifelse(str_sub(master_province$DATE,8,10)  =="JAN", 
                                 paste(str_sub(master_province$DATE, 1, 7), "-01",sep=""), 
                                 ifelse(str_sub(master_province$DATE,8,10)  =="FEB",
                                   paste(str_sub(master_province$DATE, 1, 7), "-02",sep=""),
                                   ifelse(str_sub(master_province$DATE,8,10)  =="MAR",
                                   paste(str_sub(master_province$DATE, 1, 7), "-03",sep=""),
                                   ifelse(str_sub(master_province$DATE,8,10)  =="APR",
                                   paste(str_sub(master_province$DATE, 1, 7), "-04",sep=""),
                                   paste(str_sub(master_province$DATE, 1, 7), "-05",sep="")))))
master_province$DATE <- paste(str_sub(master_province$DATE, 1, 5), str_sub(master_province$DATE, 9,10), str_sub(master_province$DATE, 5,7), sep = "") 
master_province <- master_province %>% unique()
# Remove 23rd of January for Hubei Province prefectures, DXY not collecting data properly for this day, instead it is included in the pre23 dataset for these prefectures only
master_province <- master_province %>% filter(!(ADM1_EN == "Hubei Province" & DATE == "2020-01-23"))
# merge in pre-23rd dates 
pre23_province_cases <- read.csv(file = "dxy_data/province_casecounts_preJan23.csv")
pre23_province_cases <- pre23_province_cases %>% select(-X)
pre23_province_cases <- pre23_province_cases[,c(1,2,4,5,6,7,8,3)] 
master_province <- rbind(master_province, pre23_province_cases)
write.csv(master_province, file = "dxy_data/province_master.csv")

# merge all prefecture data
prefecture_cleanNames <- list.files(path = "dxy_data/clean-daily-tables/adm-verified/prefecture", pattern = "*.csv", full.names = T)
master_prefecture <- data.frame() # empty data frame 
# merge all province data 
for (prefecture_cleanName in prefecture_cleanNames){
  daily_data <- read.csv(prefecture_cleanName) #each file will be read in, specify which columns you need read in to avoid any errors
  daily_data$X <- NULL
  daily_data$X.1 <- NULL
  master_prefecture <- rbind(master_prefecture, daily_data) #for each iteration, bind the new data to the building dataset
}
master_prefecture$DATE <- ifelse(str_sub(master_prefecture$DATE,8,10)  =="JAN", 
                                 paste(str_sub(master_prefecture$DATE, 1, 7), "-01",sep=""), 
                                 ifelse(str_sub(master_prefecture$DATE,8,10)  =="FEB",
                                        paste(str_sub(master_prefecture$DATE, 1, 7), "-02",sep=""),
                                        ifelse(str_sub(master_prefecture$DATE,8,10)  =="MAR",
                                          paste(str_sub(master_prefecture$DATE, 1, 7), "-03",sep=""),
                                          ifelse(str_sub(master_prefecture$DATE,8,10)  =="APR",
                                          paste(str_sub(master_prefecture$DATE, 1, 7), "-04",sep=""),
                                          paste(str_sub(master_prefecture$DATE, 1, 7), "-04",sep="")))))
master_prefecture$DATE <- paste(str_sub(master_prefecture$DATE, 1, 5), str_sub(master_prefecture$DATE, 9,10), str_sub(master_prefecture$DATE, 5,7), sep = "")
# overwrite the prefectures which are actually provinces 
# omit provinces from the prefectures, these counts are wrong
master_prefecture <- dplyr::filter(master_prefecture, ADM2_EN %in% master_province$ADM1_EN == FALSE)
master_prefecture <- dplyr::filter(master_prefecture, ADM2_EN != "Taiwan province")

# filter provinces to those that are prefecture level
province_prefecture <- dplyr::filter(master_province, 
                                     ADM1_EN %in% c("Beijing Municipality", "Chongqing Municipality", "Shanghai Municipality","Tianjin Municipality", "Hong Kong Special Administrative Region", "Macao Special Administrative Region", "Taiwan Province"))
province_prefecture$ADM2_EN <- ifelse(province_prefecture$ADM1_EN == "Taiwan Province" , "Taiwan province",
                                      as.character(province_prefecture$ADM1_EN)) # copy prefecture name 
province_prefecture <- province_prefecture[c(1,2,9,3,4,5,6,7,8)] # reorder columns
# merge provinces that are prefectures
master_prefecture <- rbind(master_prefecture, province_prefecture)
# remove cases in "Area to be identified", arguably would only would matter for Beijing but pull province-level data anyways 
master_prefecture <- dplyr::filter(master_prefecture, ADM2_EN != "Area to be Identified")

# add matching columns to the pre-23 dataset
master_prefecture$source_type = "DXY" # Add source_type
master_prefecture$source_url = "see dxy-html-archive folder" # Add source_url
master_prefecture$who_by = "ARW" # Add who_by
master_prefecture$access_date = "" # Add access_date, this is the dxy DATE if no date provided
master_prefecture$notes = "" # Add notes 

# Remove 23rd of January for Hubei Province prefectures, DXY not collecting data properly for this day, instead it is included in the pre23 dataset for these prefectures only
master_prefecture <- master_prefecture %>% 
  filter(!(ADM1_EN == "Hubei Province" & DATE == "2020-01-23"))
# merge in pre-23rd dates 
pre23_prefecture_cases <- read.csv(file = "dxy_data/prefecture_casecounts_preJan23.csv")
pre23_prefecture_cases <- pre23_prefecture_cases %>% select(-infection_date, -X)
master_prefecture <- rbind(master_prefecture, pre23_prefecture_cases)
# write master prefecture
write.csv(master_prefecture, file = "dxy_data/prefecture_master.csv")

# create first date of infection file 
master_prefecture <- read.csv(file = "dxy_data/prefecture_master.csv")
prefecture_firstdate <- master_prefecture %>%
  dplyr::filter(confirmedCount > 0)
prefecture_firstdate <- prefecture_firstdate %>% group_by(ADM0_EN, ADM1_EN,ADM2_EN) %>%
  summarise(date.of.notification = min(as.Date(DATE)))
# bring in prefectures that have not been infected yet 
prefecture_firstdate <- full_join(prefecture_firstdate, prefecture_adm)
prefecture_firstdate <- dplyr::filter(prefecture_firstdate, ADM2_EN != "Area to be Identified") # remove areas to be identified
write.csv(prefecture_firstdate, file = "dxy_data/prefecture_master_binary.csv")
