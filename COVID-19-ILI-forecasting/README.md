# Metadata for `us_cases_data_weekly.csv`

`us_cases_data_weekly.csv` contains weekly counts of newly reported cases in each MMWR week by state and territory (and NYC) in the United States.


## Data_name  
Data are collected from two sources  
1. State daily case counts are collected `UScases_by_state_wikipedia.csv` which comes from [wikipedia](https://en.wikipedia.org/wiki/2020_coronavirus_pandemic_in_the_United_States)  
2. County case counts are collected from [usafacts](https://static.usafacts.org/public/data/covid-19/covid_confirmed_usafacts.csv). This is used to get counts for NYC, which are then subtracted from the total NY state counts.

<b>Metadata:</b> 
`location` = state/territory/city name, matching the state submission template
`State_Code` = 2 letter state or territory code  
`date_time_accessed` = time stamp of when the wikipedia or usafacts data set was scraped  
`WeekStart` = Date format = "%Y-%m-%d%"; Date of the Sunday starting the MMWR week of the case count data  
`state_weekly_cases` = counts of new cases reported in each location for given MMWR week  
`national_weekly_cases` = counts of new cases reported in the US for given MMWR week  
`national_weekly_deaths` = counts of new deaths reported in the US for given MMWR week  
`national_weekly_rec` = counts of new recovered cases reported in the US for given MMWR week  
`epiweek` = week number used for MMWR weeks, assigned using R package "MMWRWeek"
 
<b>Related subdirectory and/or files</b>  
`weekly-covid-cases-us-collect.R` creates the `us_cases_data_weekly.csv`

<b>Projects</b>
[COVID-19 ILI forecasting Project Summary](https://docs.google.com/document/d/11YorKHfvE7Q2wGfyEcJJjXiyaWP7qHAYJNAT-jP7pO0/edit)
