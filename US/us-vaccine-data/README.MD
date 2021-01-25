This folder contains data on vaccine doses administered at the state-wide level in the United States during the COVID-19 pandemic.

There are two sources of data. One from the CDC and the other collated by the Centers for Civic impact at John's Hopkins University (govex).


## cdc-vaccine-data
This data set is directly from the CDC vaccination [dashboard](https://covid.cdc.gov/covid-data-tracker/#vaccinations). Downloading the csv from this page is not easily automated, so it will be downloaded manually and stored with the date that the data was last updated in the filename. This data set is not a time series, and so a time series will need to be created from each of these files.


<b>Metadata:</b> 

Data will update as soon as they are reviewed and verified, oftentimes before 8 pm ET. However, daily updates might be delayed due to delays in reported data.

Doses distributed information for the Federal Pharmacy Partnership for Long-Term Care (LTC) Program is not reported because distribution data cannot be separated for the Federal Pharmacy Partnership for Long-Term Care (LTC) Program, the pharmacy retail transfer program, and doses distributed from state allocations directly to pharmacies.

Data on doses of vaccine distributed and administered include those received by CDC as of 6:00 am ET on the day of reporting. Vaccination data on the CDC COVID Data Tracker are updated daily between 1:30 pm and 6:00 pm ET. Updates will occur the following day when reporting coincides with a federal holiday.

Vaccination data reported on the CDC COVID Data Tracker may differ from data reported by states and territories for several reasons:

Data may be updated on different schedules and reflect data “as of” different dates or times of day. There may be a delay between the time a vaccination record appears in a state or jurisdictional system and when it is received by CDC.
Occasionally, there may be technical issues related to processing or transmission of data. When issues arise, CDC works closely with the states, territories, and federal entities to resolve the problem.
CDC receives vaccine administration information from multiple sources, including jurisdictional immunization information systems, pharmacies, federal agencies receiving a direct vaccine allocation, and the Vaccine Administration Management System (VAMS), which supports temporary, mobile, or satellite clinics. Validation and business rules applied to prevent data duplication may cause data presented on the COVID Data Tracker to differ from what is in state immunization systems and dashboards. Every effort is made to reconcile doses administered that are reported through more than one system but, in certain circumstances, some vaccine doses administered could be counted more than once.
Healthcare providers report doses administered to federal, state, territorial, and local agencies within 72 hours of administration. There may be additional lag for data to be transmitted from the federal, state, territorial, or local agency to CDC. A large difference between the number of doses distributed and the number of people initiating vaccination is expected due to several factors including the time it takes for doses delivered to be administered, the time it takes for administered doses to be reported to CDC, and management of available vaccine stocks by jurisdictions and federal pharmacy partners.

Doses distributed and administered are reported separately for federal entities. Doses administered by federal entities are not generally attributed to the jurisdictions in which they were administered. However, some federal sites may report such doses to both the jurisdiction and to the federal entity. The “Rate per 100,000” metric displays as “n/a” for federal entities because population-based rates are not applicable. Data for federal entities will display when the “Counts” metric is selected. Veterans Health Administration (VHA) totals include employees, veteran patients, and other federal partners vaccinated by VHA.

<b>Metadata:</b> 

<b>Doses distributed</b> for U.S. States, D.C., and Puerto Rico are cumulative counts of COVID-19 vaccine doses reported to Operation Warp Speed as delivered since December 14, 2020. Doses distributed to the U.S. Virgin Islands, Palau, Micronesia, Marshall Islands, Guam, American Samoa, and Northern Marianas Islands include those marked as shipped in in CDC’s Vaccine Tracking System (VTrckS) since December 13, 2020. Doses distributed to a state or territory also include those distributed to pharmacies in the jurisdiction. On January 20, 2021, CDC COVID Data Tracker moved from reporting doses shipped to doses delivered for U.S. States, D.C., and Puerto Rico.

</b>Total doses administered</b> are cumulative counts of individual COVID-19 vaccine doses administered as reported to CDC by state, territorial, and local public health agencies and federal entities since December 14, 2020.

</b>People receiving 1 or more doses</b> represent the total number of people who have received at least one dose of vaccine. People receiving 2 doses represent the number of people who have also received a second dose of vaccine. **The number of people receiving 1 or more doses and the number of people receiving 2 doses were determined based on information reported to CDC by state, territorial, and local public health agencies and federal entities on dose number, administration date, recipient ID, and date of submission. Because the method used to determine dose numbers needs to be applied across multiple jurisdictions with different reporting practices, CDC’s dose number estimates may differ from those reported by jurisdictions and federal entities. A dose number was determined for nearly all reported doses administered but, because there are some missing data for dose number, the sum of people receiving 1 or more doses and people receiving 2 doses will not exactly equal the total doses administered.

</b>Long-term care facility (LTCF) data</b> are specific to the Federal Pharmacy Partnership for Long-Term Care (LTC) Program and primarily include skilled nursing and assisted living facilities. Doses administered refers to vaccine administered to LTCF residents and staff, as reported to CDC by the pharmacy partners participating in the program. These data do not include doses administered to LTCF residents and staff outside the Federal Pharmacy Partnership for Long-Term Care Program. Vaccine administration through the federal program launched nationally on December 21 for Pfizer-BioNTech vaccine and on December 28 for Moderna vaccine. As of January 4, 2021, a total of 56 jurisdictions have started the program. Program start dates varied based on the jurisdiction.

</b>Rates per 100,000 population</b> use the U.S. Census Bureau 2019 American Community Survey 1-year population estimates. 2018 population estimates are used for American Samoa, Federated States of Micronesia, Guam, Northern Mariana Islands, Palau, Republic of Marshall Islands, and United States Virgin Islands. Differences in the relative size of populations targeted for vaccination across jurisdictions should be considered when comparing population-based rates across jurisdictions.



## state-vaccine-data-govex

This data set is downloaded automatically from the Center for Civic Impact at JHU's github [repository](https://github.com/govex/COVID-19/blob/master/data_tables/vaccine_data/raw_data/vaccine_data_us_state_timeline.csv). The data are collated from state-level dashboards. For links to each dashboard see the readme file within the subfolder. It will be downloaded automatically and since the data are in a timeseries, earlier versions will be overwritten. The data dictionary is in a csv and is also downloaded automatically.
 
 <b>Metadata:</b>
- `date`: data collection date
- `Province_State`: US State name
- `stabbr`: US State name abbreviation
- `dashboard_available`: 'Yes' when there is a publicly available dashboard with vaccine information. 'No' otherwise
- `doses_alloc_total`: Total cumulative number of COVID-19 vaccine doses allocated
- `doses_alloc_moderna`: Cumulative number of Moderna COVID-19 vaccine doses allocated
- `doses_alloc_pfizer`: Cumulative number of Pfizer COVID-19 vaccine doses allocated
- `doses_alloc_unknown`: Cumulative number of COVID-19 vaccine doses allocated from an unknown provider
- `doses_shipped_total`: Total cumulative number of COVID-19 vaccine doses shipped
- `doses_shipped_moderna`: Cumulative number of Moderna COVID-19 vaccine doses shipped
- `doses_shipped_pfizer`: Cumulative number of Pfizer COVID-19 vaccine doses shipped
- `doses_shipped_unknown`: Cumulative number of COVID-19 vaccine doses shipped from an unknown provider
- `doses_admin_total`: Total cumulative number of COVID-19 vaccine doses administered
- `doses_admin_moderna`: Cumulative number of Moderna COVID-19 vaccine doses administered
- `doses_admin_pfizer`: Cumulative number of Pfizer COVID-19 vaccine doses administered
- `doses_admin_unknown`: Cumulative number of COVID-19 vaccine doses administered from an unknown provider
- `people_total`: "Total cumulative number of people vaccinated, with only one dose administered"
- `people_total_2nd_dose`: "Total cumulative number of people fully vaccinated, with all doses administered"
