#!/bin/bash

# script to download apple-mobility data
# iterates over a range of dates as we don't know which will work based on update times

#function to test if the url is valid
function validate_url(){
          if [[ `wget -S --spider $1  2>&1 | grep 'HTTP/1.1 200 OK'` ]]; then return 0; else return 1; fi
         }


#1 day prior
downloaddate=$(date --date="yesterday" +%F)

url="https://covid19-static.cdn-apple.com/covid19-mobility-data/2007HotfixDev58/v2/en-us/applemobilitytrends-${downloaddate}.csv"

if `validate_url $url`; then wget -O global/global_apple_covid_mobility_reports/global_apple_mobility_report.csv $url; else echo "download fails for $downloaddate"; fi

#2 day prior
downloaddate=$(date --date="2 days ago" +%F)

url="https://covid19-static.cdn-apple.com/covid19-mobility-data/2007HotfixDev58/v2/en-us/applemobilitytrends-${downloaddate}.csv"

if `validate_url $url`; then wget -O global/global_apple_covid_mobility_reports/global_apple_mobility_report.csv $url; else echo "download fails for $downloaddate"; fi

#3 day prior
downloaddate=$(date --date="3 days ago" +%F)

url="https://covid19-static.cdn-apple.com/covid19-mobility-data/2007HotfixDev58/v2/en-us/applemobilitytrends-${downloaddate}.csv"

if `validate_url $url`; then wget -O global/global_apple_covid_mobility_reports/global_apple_mobility_report.csv $url; else echo "download fails for $downloaddate"; fi

#4 day prior
downloaddate=$(date --date="4 days ago" +%F)

url="https://covid19-static.cdn-apple.com/covid19-mobility-data/2007HotfixDev58/v2/en-us/applemobilitytrends-${downloaddate}.csv"

if `validate_url $url`; then wget -O global/global_apple_covid_mobility_reports/global_apple_mobility_report.csv $url; else echo "download fails for $downloaddate"; fi
