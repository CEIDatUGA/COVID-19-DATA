
<!-- ![gdph-daily-charts](https://github.com/CEIDatUGA/COVID-19-DATA/workflows/gdph-daily-charts/badge.svg)
     ![gdph-daily-status](https://github.com/CEIDatUGA/COVID-19-DATA/workflows/gdph-daily-status/badge.svg) -->
![china-dxy-download](https://github.com/CEIDatUGA/COVID-19-DATA/workflows/china-dxy-download/badge.svg)
![gdph-daily](https://github.com/CEIDatUGA/COVID-19-DATA/workflows/gdph-daily-download/badge.svg)
![world-cases-wiki-scrape](https://github.com/CEIDatUGA/COVID-19-DATA/workflows/world-data-wiki-scrape/badge.svg)
![google-mobility](https://github.com/CEIDatUGA/COVID-19-DATA/workflows/google-mobility/badge.svg)
![intervention-data-update](https://github.com/CEIDatUGA/COVID-19-DATA/workflows/intervention-data-update/badge.svg)
![us-cases-wiki-scrape](https://github.com/CEIDatUGA/COVID-19-DATA/workflows/us-cases-wiki-scrape/badge.svg)
![china-dxy-update](https://github.com/CEIDatUGA/COVID-19-DATA/workflows/china-dxy-update/badge.svg)
![github-update](https://github.com/CEIDatUGA/COVID-19-DATA/workflows/github-update/badge.svg)

Repository that stores datasets used in different COVID CEID projects.
=======
The datasets in the repository were compiled by members of the CEID COVID-19 working group. The data at the top level of the repository have been formated to be used 'as-is' and are updated often. Data sets were either created from html scraping or manually entered. In the case of the automated web scraping, the raw data and scripts are organized into sub-directories. The description of each data file along with the corresponding sub-directories are listed below. The metadata is in the readme of the same directory as the data.


## China data
**China_casedata** </br>
**China_TA**: Travel advisories or restrictions within China. </br>
**Hubei_Evacuation_Repatriation**: Reports of evacuations from Hubei province. </br>

## US data  
**US_wikipedia_cases_fatalities/UScases_by_state_wikipedia.csv**: Number of new cases in a state by day. </br>
**US_wikipedia_cases_fatalities/USfatalities_by_state_wikipedia.csv**: Number of new case fatalities in a state by day.  </br>

**us-state-intervention-data/stateInterventionTimeSeries.csv**: Reshaped version of longFormStateInterventions.csv that includes the intervention status of all US states on each date since the beginning of the outbreak. Updated daily. </br>
**us-state-intervention-data/longFormStateInterventions.csv**: Running summary of interventions at the state level taken from reports and wikipedia

**COVID-19-ILI-forecasting/us_cases_data_weekly.csv**: weekly counts of newly reported cases in each MMWR week by state and territory (and NYC) in the United States

**us_nursing_homes_HIFLD.csv**: locations and some metadata (number of residents, beds, etc.) for nursing homes in all 50 states

**us-airports.csv**: list and location of airports in the US

**us-early-linelist/US_early_linelist.xlsx**: Individual infection histories of US COVID19 cases from early in the outbreak that were manually collected from media reports. 

## Georgia Data

**ga-county-intervention-data/countyInterventionTimeSeries.csv**: Reshaped version of longFormStateInterventions.csv that includes the intervention status of all US states on each date since the beginning of the outbreak. Updated daily. </br>
**ga-county-intervention-data/longFormCountyInterventions.csv**: Running summary of interventions at the state level taken from reports and wikipedia

**ga_DGPH_daily_status_report**: daily cases, fatatliies, and tests in the state of Gerogia. Also includes demography about cases.  `GA-DPH-CanvasJS-data-cases-deaths.csv` is an alternate scrape of this data.</br>

**georgia_icu_beds.csv**: number of icu beds by county for Georgia

## Global
**global_cases_by_country/worldCases.csv**: Number of new cases in a country by day. </br>
**global_cases_by_country/worldFatalities.csv**: Number of new fatalities in a country by day. </br>

**International_TA**: Travel advisories announced by county. </br>
**Global Health Security Index (GHSI)**: Index of epidemic preparednessa and underlying data </br>
**Epidemiological characteristics of COVID-19 and other zoonotics**)</br>
**Canada COVID-19 Case Data**: Includes cases, fatalities, recovered, and tested for Canada</br>
**global_exposure_locations.csv**: information on where cases were exposed to the virus</br>
**global_first_case.csv**: First case for every ADM1 globally</br>
**Global Google Mobility Report**: Daily mobility data by country for the globe beginning in Feb 2020. Disaggregated by types of places visitied. </br>

---





# How to add new data?

Please follow the data protocols outlines [here](https://docs.google.com/document/d/1JwN1Q8ILKEU48sDo-f44V2wLErFm29rh0TI9hMXMwEk/edit). Use the template below to add metadata about your dataset to its subdirectory, and add the name of the dataset to this master README.

## Data_name
Here is some discription of how the data is collected, when it is normally updated, etc. 

<b>Metadata:</b> 
 
<b>Source:</b> Link to data source if pulled from single website (ie. Wikipedia, etc.)

<b>Related subdirectory and/or files</b>

<b>Projects</b>
List/Link related projects

# License 
See License.txt

Contact John Drake (jdrake@uga.edu) for questions. 

