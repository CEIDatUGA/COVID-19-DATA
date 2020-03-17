library(httr)
library(xml2)
library(rvest)
library(tidyverse)
library(magrittr)

# no longer pulling directly from html site 
# url <- "https://3g.dxy.cn/newh5/view/pneumonia?scene=2&clicktime=1579579384&enterid=1579579384&from=groupmessage&isappinstalled=0" # public website
# webpage <- read_html(url) #pull text from webpage

# Instead, saving daily html file 6-12 pm EST 
# list out all file names and dates 
fileNames <- c("23JAN2020","24JAN2020","25JAN2016","26JAN2034","27JAN2021","28JAN2031","29JAN2027",
               "30JAN2032","31JAN2025","01FEB1921","02FEB1928","03FEB2331","04FEB2132","05FEB2302", 
               "06FEB1641","07FEB1639","08FEB2153","09FEB1936","10FEB2209","11FEB1825","12FEB2234", 
               "13FEB2103","14FEB1943","15FEB1934","16FEB1644","17FEB1921","18FEB2034","19FEB2000",
               "20FEB2359","21FEB2128","22FEB2026","23FEB1936","24FEB2028", "25FEB1830","26FEB2121",
               "27FEB2003","28FEB1954","29FEB2041","01MAR2052","02MAR2019","03MAR2050","04MAR1931",
               "05MAR1957","06MAR1804","07MAR1753","08MAR2347","09MAR2106","10MAR1946","11MAR1939",
               "12MAR2339","13MAR2113","14MAR2336")#,"15MAR1449","16MAR2031")

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
names(test)[1]<-"text"
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
test$n_variable <- NULL 
# remove unneccessary variables (cities, NA)
test <- dplyr::filter(test, variable != "cities")
test <- dplyr::filter(test, variable != "")
test <- dplyr::filter(test, v1 != "")
# test <- dplyr::filter(test, "待明确地区") # remove Area to be Identified 

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

cleanTables <- c("23JAN","24JAN","25JAN","26JAN","27JAN","28JAN","29JAN", 
                 "30JAN","31JAN","01FEB","02FEB","03FEB","04FEB","05FEB",
                 "06FEB","07FEB","08FEB","09FEB","10FEB","11FEB","12FEB",
                 "13FEB","14FEB","15FEB","16FEB","17FEB","18FEB","19FEB",
                 "20FEB","21FEB","22FEB","23FEB","24FEB","25FEB","26FEB",
                 "27FEB","28FEB","29FEB","01MAR","02MAR","03MAR","04MAR",
                 "05MAR","06MAR","07MAR","08MAR","09MAR","10MAR","11MAR",
                 "12MAR","13MAR","14MAR")#,"15MAR","16MAR") 
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
write.csv(province_cases, file = paste("dxy_data/clean-daily-tables/adm-verified/province_", cleanTable, "2020.csv", sep = ""))

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
write.csv(master_case, file = paste("dxy_data/clean-daily-tables/adm-verified/prefecture_",cleanTable, "2020.csv", sep = ""))
}

# merge all province data 
JAN23 <- read.csv(file = "dxy_data/clean-daily-tables/adm-verified/province_23JAN2020.csv")
JAN24 <- read.csv(file = "dxy_data/clean-daily-tables/adm-verified/province_24JAN2020.csv")
JAN25 <- read.csv(file = "dxy_data/clean-daily-tables/adm-verified/province_25JAN2020.csv")
JAN26 <- read.csv(file = "dxy_data/clean-daily-tables/adm-verified/province_26JAN2020.csv")
JAN27 <- read.csv(file = "dxy_data/clean-daily-tables/adm-verified/province_27JAN2020.csv")
JAN28 <- read.csv(file = "dxy_data/clean-daily-tables/adm-verified/province_28JAN2020.csv")
JAN29 <- read.csv(file = "dxy_data/clean-daily-tables/adm-verified/province_29JAN2020.csv")
JAN30 <- read.csv(file = "dxy_data/clean-daily-tables/adm-verified/province_30JAN2020.csv")
JAN31 <- read.csv(file = "dxy_data/clean-daily-tables/adm-verified/province_31JAN2020.csv")
FEB01 <- read.csv(file = "dxy_data/clean-daily-tables/adm-verified/province_01FEB2020.csv")
FEB02 <- read.csv(file = "dxy_data/clean-daily-tables/adm-verified/province_02FEB2020.csv")
FEB03 <- read.csv(file = "dxy_data/clean-daily-tables/adm-verified/province_03FEB2020.csv")
FEB04 <- read.csv(file = "dxy_data/clean-daily-tables/adm-verified/province_04FEB2020.csv")
FEB05 <- read.csv(file = "dxy_data/clean-daily-tables/adm-verified/province_05FEB2020.csv")
FEB06 <- read.csv(file = "dxy_data/clean-daily-tables/adm-verified/province_06FEB2020.csv")
FEB07 <- read.csv(file = "dxy_data/clean-daily-tables/adm-verified/province_07FEB2020.csv")
FEB08 <- read.csv(file = "dxy_data/clean-daily-tables/adm-verified/province_08FEB2020.csv")
FEB09 <- read.csv(file = "dxy_data/clean-daily-tables/adm-verified/province_09FEB2020.csv")
FEB10 <- read.csv(file = "dxy_data/clean-daily-tables/adm-verified/province_10FEB2020.csv")
FEB11 <- read.csv(file = "dxy_data/clean-daily-tables/adm-verified/province_11FEB2020.csv")
FEB12 <- read.csv(file = "dxy_data/clean-daily-tables/adm-verified/province_12FEB2020.csv")
FEB13 <- read.csv(file = "dxy_data/clean-daily-tables/adm-verified/province_13FEB2020.csv")
FEB14 <- read.csv(file = "dxy_data/clean-daily-tables/adm-verified/province_14FEB2020.csv")
FEB15 <- read.csv(file = "dxy_data/clean-daily-tables/adm-verified/province_15FEB2020.csv")
FEB16 <- read.csv(file = "dxy_data/clean-daily-tables/adm-verified/province_16FEB2020.csv")
FEB17 <- read.csv(file = "dxy_data/clean-daily-tables/adm-verified/province_17FEB2020.csv")
FEB18 <- read.csv(file = "dxy_data/clean-daily-tables/adm-verified/province_18FEB2020.csv")
FEB19 <- read.csv(file = "dxy_data/clean-daily-tables/adm-verified/province_19FEB2020.csv")
FEB20 <- read.csv(file = "dxy_data/clean-daily-tables/adm-verified/province_20FEB2020.csv")
FEB21 <- read.csv(file = "dxy_data/clean-daily-tables/adm-verified/province_21FEB2020.csv")
FEB22 <- read.csv(file = "dxy_data/clean-daily-tables/adm-verified/province_22FEB2020.csv")
FEB23 <- read.csv(file = "dxy_data/clean-daily-tables/adm-verified/province_23FEB2020.csv")
FEB24 <- read.csv(file = "dxy_data/clean-daily-tables/adm-verified/province_24FEB2020.csv")
FEB25 <- read.csv(file = "dxy_data/clean-daily-tables/adm-verified/province_25FEB2020.csv")
FEB26 <- read.csv(file = "dxy_data/clean-daily-tables/adm-verified/province_26FEB2020.csv")
FEB27 <- read.csv(file = "dxy_data/clean-daily-tables/adm-verified/province_27FEB2020.csv")
FEB28 <- read.csv(file = "dxy_data/clean-daily-tables/adm-verified/province_28FEB2020.csv")
FEB29 <- read.csv(file = "dxy_data/clean-daily-tables/adm-verified/province_29FEB2020.csv")
MAR01 <- read.csv(file = "dxy_data/clean-daily-tables/adm-verified/province_01MAR2020.csv")
MAR02 <- read.csv(file = "dxy_data/clean-daily-tables/adm-verified/province_02MAR2020.csv")
MAR03 <- read.csv(file = "dxy_data/clean-daily-tables/adm-verified/province_03MAR2020.csv")
MAR04 <- read.csv(file = "dxy_data/clean-daily-tables/adm-verified/province_04MAR2020.csv")
MAR05 <- read.csv(file = "dxy_data/clean-daily-tables/adm-verified/province_05MAR2020.csv")
MAR06 <- read.csv(file = "dxy_data/clean-daily-tables/adm-verified/province_06MAR2020.csv")
MAR07 <- read.csv(file = "dxy_data/clean-daily-tables/adm-verified/province_07MAR2020.csv")
MAR08 <- read.csv(file = "dxy_data/clean-daily-tables/adm-verified/province_08MAR2020.csv")
MAR09 <- read.csv(file = "dxy_data/clean-daily-tables/adm-verified/province_09MAR2020.csv")
MAR10 <- read.csv(file = "dxy_data/clean-daily-tables/adm-verified/province_10MAR2020.csv")
MAR11 <- read.csv(file = "dxy_data/clean-daily-tables/adm-verified/province_11MAR2020.csv")
MAR12 <- read.csv(file = "dxy_data/clean-daily-tables/adm-verified/province_12MAR2020.csv")
MAR13 <- read.csv(file = "dxy_data/clean-daily-tables/adm-verified/province_13MAR2020.csv")
MAR14 <- read.csv(file = "dxy_data/clean-daily-tables/adm-verified/province_14MAR2020.csv")
#MAR15 <- read.csv(file = "dxy_data/clean-daily-tables/adm-verified/province_15MAR2020.csv")
#MAR16 <- read.csv(file = "dxy_data/clean-daily-tables/adm-verified/province_16MAR2020.csv")

master_province <- rbind(JAN23,JAN24,JAN25,JAN26,JAN27,JAN28,JAN29,JAN30, 
                         JAN31,FEB01,FEB02,FEB03,FEB04,FEB05,FEB06,FEB07,
                         FEB08,FEB09,FEB10,FEB11,FEB12,FEB13,FEB14,FEB15,
                         FEB16,FEB17,FEB18,FEB19,FEB20,FEB21,FEB22,FEB23,
                         FEB24,FEB25,FEB26,FEB27,FEB28,FEB29,MAR01,MAR02,
                         MAR03,MAR04,MAR05,MAR06,MAR07,MAR08,MAR09,MAR10,
                         MAR11,MAR12,MAR13,MAR14)#,MAR15,MAR16)
master_province$X <- NULL
master_province$X.1 <- NULL
master_province <- unique(master_province)
master_province$DATE <- ifelse(str_sub(master_province$DATE,8,10)  =="JAN", 
                                 paste(str_sub(master_province$DATE, 1, 7), "-01",sep=""), 
                                 ifelse(str_sub(master_province$DATE,8,10)  =="FEB",
                                   paste(str_sub(master_province$DATE, 1, 7), "-02",sep=""),
                                   paste(str_sub(master_province$DATE, 1, 7), "-03",sep="")))
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
JAN23 <- read.csv(file = "dxy_data/clean-daily-tables/adm-verified/prefecture_23JAN2020.csv")
JAN24 <- read.csv(file = "dxy_data/clean-daily-tables/adm-verified/prefecture_24JAN2020.csv")
JAN25 <- read.csv(file = "dxy_data/clean-daily-tables/adm-verified/prefecture_25JAN2020.csv")
JAN26 <- read.csv(file = "dxy_data/clean-daily-tables/adm-verified/prefecture_26JAN2020.csv")
JAN27 <- read.csv(file = "dxy_data/clean-daily-tables/adm-verified/prefecture_27JAN2020.csv")
JAN28 <- read.csv(file = "dxy_data/clean-daily-tables/adm-verified/prefecture_28JAN2020.csv")
JAN29 <- read.csv(file = "dxy_data/clean-daily-tables/adm-verified/prefecture_29JAN2020.csv")
JAN30 <- read.csv(file = "dxy_data/clean-daily-tables/adm-verified/prefecture_30JAN2020.csv")
JAN31 <- read.csv(file = "dxy_data/clean-daily-tables/adm-verified/prefecture_31JAN2020.csv")
FEB01 <- read.csv(file = "dxy_data/clean-daily-tables/adm-verified/prefecture_01FEB2020.csv")
FEB02 <- read.csv(file = "dxy_data/clean-daily-tables/adm-verified/prefecture_02FEB2020.csv")
FEB03 <- read.csv(file = "dxy_data/clean-daily-tables/adm-verified/prefecture_03FEB2020.csv")
FEB04 <- read.csv(file = "dxy_data/clean-daily-tables/adm-verified/prefecture_04FEB2020.csv")
FEB05 <- read.csv(file = "dxy_data/clean-daily-tables/adm-verified/prefecture_05FEB2020.csv")
FEB06 <- read.csv(file = "dxy_data/clean-daily-tables/adm-verified/prefecture_06FEB2020.csv")
FEB07 <- read.csv(file = "dxy_data/clean-daily-tables/adm-verified/prefecture_07FEB2020.csv")
FEB08 <- read.csv(file = "dxy_data/clean-daily-tables/adm-verified/prefecture_08FEB2020.csv")
FEB09 <- read.csv(file = "dxy_data/clean-daily-tables/adm-verified/prefecture_09FEB2020.csv")
FEB10 <- read.csv(file = "dxy_data/clean-daily-tables/adm-verified/prefecture_10FEB2020.csv")
FEB11 <- read.csv(file = "dxy_data/clean-daily-tables/adm-verified/prefecture_11FEB2020.csv")
FEB12 <- read.csv(file = "dxy_data/clean-daily-tables/adm-verified/prefecture_12FEB2020.csv")
FEB13 <- read.csv(file = "dxy_data/clean-daily-tables/adm-verified/prefecture_13FEB2020.csv")
FEB14 <- read.csv(file = "dxy_data/clean-daily-tables/adm-verified/prefecture_14FEB2020.csv")
FEB15 <- read.csv(file = "dxy_data/clean-daily-tables/adm-verified/prefecture_15FEB2020.csv")
FEB16 <- read.csv(file = "dxy_data/clean-daily-tables/adm-verified/prefecture_16FEB2020.csv")
FEB17 <- read.csv(file = "dxy_data/clean-daily-tables/adm-verified/prefecture_17FEB2020.csv")
FEB18 <- read.csv(file = "dxy_data/clean-daily-tables/adm-verified/prefecture_18FEB2020.csv")
FEB19 <- read.csv(file = "dxy_data/clean-daily-tables/adm-verified/prefecture_19FEB2020.csv")
FEB20 <- read.csv(file = "dxy_data/clean-daily-tables/adm-verified/prefecture_20FEB2020.csv")
FEB21 <- read.csv(file = "dxy_data/clean-daily-tables/adm-verified/prefecture_21FEB2020.csv")
FEB22 <- read.csv(file = "dxy_data/clean-daily-tables/adm-verified/prefecture_22FEB2020.csv")
FEB23 <- read.csv(file = "dxy_data/clean-daily-tables/adm-verified/prefecture_23FEB2020.csv")
FEB24 <- read.csv(file = "dxy_data/clean-daily-tables/adm-verified/prefecture_24FEB2020.csv")
FEB25 <- read.csv(file = "dxy_data/clean-daily-tables/adm-verified/prefecture_25FEB2020.csv")
FEB26 <- read.csv(file = "dxy_data/clean-daily-tables/adm-verified/prefecture_26FEB2020.csv")
FEB27 <- read.csv(file = "dxy_data/clean-daily-tables/adm-verified/prefecture_27FEB2020.csv")
FEB28 <- read.csv(file = "dxy_data/clean-daily-tables/adm-verified/prefecture_28FEB2020.csv")
FEB29 <- read.csv(file = "dxy_data/clean-daily-tables/adm-verified/prefecture_29FEB2020.csv")
MAR01 <- read.csv(file = "dxy_data/clean-daily-tables/adm-verified/prefecture_01MAR2020.csv")
MAR02 <- read.csv(file = "dxy_data/clean-daily-tables/adm-verified/prefecture_02MAR2020.csv")
MAR03 <- read.csv(file = "dxy_data/clean-daily-tables/adm-verified/prefecture_03MAR2020.csv")
MAR04 <- read.csv(file = "dxy_data/clean-daily-tables/adm-verified/prefecture_04MAR2020.csv")
MAR05 <- read.csv(file = "dxy_data/clean-daily-tables/adm-verified/prefecture_05MAR2020.csv")
MAR06 <- read.csv(file = "dxy_data/clean-daily-tables/adm-verified/prefecture_06MAR2020.csv")
MAR07 <- read.csv(file = "dxy_data/clean-daily-tables/adm-verified/prefecture_07MAR2020.csv")
MAR08 <- read.csv(file = "dxy_data/clean-daily-tables/adm-verified/prefecture_08MAR2020.csv")
MAR09 <- read.csv(file = "dxy_data/clean-daily-tables/adm-verified/prefecture_09MAR2020.csv")
MAR10 <- read.csv(file = "dxy_data/clean-daily-tables/adm-verified/prefecture_10MAR2020.csv")
MAR11 <- read.csv(file = "dxy_data/clean-daily-tables/adm-verified/prefecture_11MAR2020.csv")
MAR12 <- read.csv(file = "dxy_data/clean-daily-tables/adm-verified/prefecture_12MAR2020.csv")
MAR13 <- read.csv(file = "dxy_data/clean-daily-tables/adm-verified/prefecture_13MAR2020.csv")
MAR14 <- read.csv(file = "dxy_data/clean-daily-tables/adm-verified/prefecture_14MAR2020.csv")
#MAR15 <- read.csv(file = "dxy_data/clean-daily-tables/adm-verified/prefecture_15MAR2020.csv")
#MAR16 <- read.csv(file = "dxy_data/clean-daily-tables/adm-verified/prefecture_16MAR2020.csv")

master_prefecture <- rbind(JAN23,JAN24,JAN25,JAN26,JAN27,JAN28,JAN29,
                           JAN30,JAN31,FEB01,FEB02,FEB03,FEB04,FEB05,
                           FEB06,FEB07,FEB08,FEB09,FEB10,FEB11,FEB12, 
                           FEB13,FEB14,FEB15,FEB16,FEB17,FEB18,FEB19,
                           FEB20,FEB21,FEB22,FEB23,FEB24,FEB25,FEB26,
                           FEB27,FEB28,FEB29,MAR01,MAR02,MAR03,MAR04,
                           MAR05,MAR06,MAR07,MAR08,MAR09,MAR10,MAR11,
                           MAR12,MAR13,MAR14)#,MAR15,MAR16)
master_prefecture$X <- NULL
master_prefecture$X.1 <- NULL
master_prefecture$DATE <- ifelse(str_sub(master_prefecture$DATE,8,10)  =="JAN", 
                                 paste(str_sub(master_prefecture$DATE, 1, 7), "-01",sep=""), 
                                 ifelse(str_sub(master_prefecture$DATE,8,10)  =="FEB",
                                        paste(str_sub(master_prefecture$DATE, 1, 7), "-02",sep=""), 
                                        paste(str_sub(master_prefecture$DATE, 1, 7), "-03",sep="")))
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
master_prefecture$access_date = paste(cleanTable, "2020", sep = "") # Add access_date
master_prefecture$notes = "" # Add notes 

# Remove 23rd of January for Hubei Province prefectures, DXY not collecting data properly for this day, instead it is included in the pre23 dataset for these prefectures only
master_prefecture <- master_prefecture %>% filter(!(ADM1_EN == "Hubei Province" & DATE == "2020-01-23"))
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

