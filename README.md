
![gdph-daily-charts](https://github.com/CEIDatUGA/COVID-19-DATA/workflows/gdph-daily-charts/badge.svg)
![gdph-daily-status](https://github.com/CEIDatUGA/COVID-19-DATA/workflows/gdph-daily-status/badge.svg)
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
**UScases_by_state_wikipedia.csv**: Number of new cases in a state by day. </br>
**USfatalities_by_state_wikipedia.csv**: Number of new case fatalities in a state by day.  </br>
**us-state-intervention-data/stateInterventionTimeSeries.csv**: Reshaped version of longFormStateInterventions.csv that includes the intervention status of all US states on each date since the beginning of the outbreak. Updated daily. </br>

**us-state-intervention-data/longFormStateInterventions.csv**: Running summary of interventions at the state level taken from reports and wikipedia

**ga-county-intervention-data/countyInterventionTimeSeries.csv**: Reshaped version of longFormStateInterventions.csv that includes the intervention status of all US states on each date since the beginning of the outbreak. Updated daily. </br>

**ga-county-intervention-data/longFormCountyInterventions.csv**: Running summary of interventions at the state level taken from reports and wikipedia

## Global
**worldCases.csv**: Number of new cases in a country by day. </br>
**Internation_TA**: Travel advisories announced by county. </br>
**Global Health Security Index**: Index of epidemic preparednessa and underlying data </br>
**Epidemiological characteristics of COVID-19 and other zoonotics**)</br>
**Canada COVID-19 Case Data**: Includes cases, fatalities, recovered, and tested for Canada

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

