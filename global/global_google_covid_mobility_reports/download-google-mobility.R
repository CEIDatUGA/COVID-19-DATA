# Download Google Mobility Data
# MV Evans, August 2020

#' This script downloads the google mobility data, parses it out
#' by country so the files are smaller enough to save, and saves 
#' it as seperate csvs.

options(stringsAsFactors = F)

library(data.table)

dir.path = "global/global_google_covid_mobility_reports/"

download.file("https://www.gstatic.com/covid19/mobility/Global_Mobility_Report.csv?cachebust=911a386b6c9c230f",
                            destfile = paste0(dir.path, "global_google_mobility_report.csv"))

google.all <- fread(paste0(dir.path, "global_google_mobility_report.csv"))

#create little subsets and save
countries <- unique(google.all$country_region)


countries.per.file <- 10 #let's do 10 countries per file
n.subsets <- ceiling(length(countries)/countries.per.file)

#use a for-loop because I am a monster
for (i in 1:n.subsets){
  first.ind = (i-1)*countries.per.file+1
  last.ind = i*countries.per.file+1
  #get that last odd chunk
  if(last.ind>length(countries)) last.ind = length(countries)
  this.countries <- countries[first.ind:last.ind]
  this.subset <- google.all[country_region %in% this.countries]
  this.filename <- paste("google_mobility", gsub(" ", "-", countries[first.ind]), gsub(" ", "-", countries[last.ind]), sep = "_")
  #save
  write.csv(this.subset, paste0(dir.path, "/", this.filename, ".csv"), row.names = F)
}


#delete inital file that is too big
unlink(paste0(dir.path, "global_google_mobility_report.csv"))
