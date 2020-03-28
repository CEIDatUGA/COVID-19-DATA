## Date and location of first case at ADM1 level

This dataset contains information on the date and location of the first case for every ADM1 (first level below national). It is downloaded from https://docs.google.com/spreadsheets/d/1eA5YOdaZvEhDcse4W6qq7Q_D8AciZx_1ZSgORxUppGo/edit#gid=0.

**Metadata**
|Variable          |Definition                                                                                |
|:-----------------|:-----------------------------------------------------------------------------------------|
|Country           |Country name                                                                              |
|ADM1_type         |type of ADM1 boundary                                                                     |
|ADM1_name         |name of AMD1 boundary (from GADM)                                                         |
|Location          |location of case, city, airport, hospital, etc.                                           |
|confirmation_date |date that case was confirmed and publicly announced, "YYYY-MM-DD" format                  |
|importation_date  |date that case entered destination country, "YYYY-MM-DD" format                           |
|treatment_date    |date patient sought treatment, or was identified as a suspected case, "YYYY-MM-DD" format |
|source            |url of original source, preferably government report, also can be news source             |
|source_type       |type of source, either government, or news, etc.                                          |
|notes             |notes of interest from report                                                             |
|source2           |additional sources                                                                        |
|accessed_date     |date source last accessed "YYYY-MM-DD" format                                             |
|accessed_by       |initials of who accessed data source                                                      |
|last_date_checked |NA                                                                                        |


**Associated Projects:**

**Sources:** Multiple sources noted in the dataset.

## COVID-19 Global Case Data: Exposure Locations

This dataset contains information on where cases were exposed to the virus (i.e. if it was from trave to China, etc.) It is downloaded from https://docs.google.com/spreadsheets/d/150Kc-hjh9uPTNigEL6L0E8i0KTF77utMmSu1AdSRAgY/edit#gid=0.

**Metadata**
|report_date                                      |date WHO situation report was published, in format "YYYY-MM-DD"                                                                  |
|:------------------------------------------------|:--------------------------------------------------------------------------------------------------------------------------------|
|data_date                                        |most recent date that data in report was from. can be found at beginning of table, in format "YYYY-MM-DD"                        |
|Country                                          |Country (outside of China), keep spelling matching WHO report                                                                    |
|confirmed_cases_total                            |total (cumulative) number of confirmed cases in each country                                                                     |
|cases_total_china_exposure                       |total (cumulative) number of confirmed cases in each country that had exposure in China                                          |
|cases_total_outside_china_exposure_international |total (cumulative) number of cases in each country that had international exposure outside of China, and also not local exposure |
|cases_total_local_exposure                       |total (cumulative) number of cases in each country that had local (not international) exposure                                   |
|cases_total_unknown_exposure                     |total (cumulative) number of cases where exposure is unknown, or still under investigation                                       |
|country_of_exposure                              |if exposure occcurred outside of China and is not local transmission, the country of exposure                                    |
|source                                           |url of WHO situation report                                                                                                      |
|accessed_by                                      |initials of who accessed source                                                                                                  |
|accessed_date                                    |date report url was accessed, format "YYYY-MM-DD"                                                                                |
|notes                                            |any notes from WHO report text that are relevant, interesting                                                                    |
|NA                                               |NA                                                                                                                               |


**Projects using this data:**

**Source:** This is sourced from multiple online reports, noted in the dataset.

## International_TA

This dataset contains travel restrictions enacted between China and various entities (countries, airlines, etc.) as well as other quarantines and travel restrictions enacted outside of China. This data is downloaded via the `google_sheets_update.R` script from https://docs.google.com/spreadsheets/d/1cYqkGOy4ZjHSIeRqyfyi7UvYnG6-UlBAJWD8GMFZA7I/edit#gid=1169808441

<b>Metadata: </b> </br>
- city_source: city of origin where travel restriction pertains to
- ADM2_source: ADM2 name of origin where travel restriction pertains to
- ADM1_source: ADM1 name of origin where travel restriction pertains to
- country_source: country of origin where travel restriction pertains to
- country_code_source: country code of origin
- city_destination: city of destination where restriction is in place
- ADM2_destination: ADM2 name of destination where restriction is in place
- ADM1_destination: ADM1 name of destination where restriction is in place
- country_destination: name of country that enacted a travel restriction
- country_code_destination: iso2 code of country that enacted a travel restriction: https://en.wikipedia.org/wiki/ISO_3166- 1_alpha- 2
- travel_advisor: name of entity that announced travel restriction
- travel_advisor_type: type of entity that announced travel restriction (e.g. government, corporate, etc.)
- travel_restriction_date: date travel restriction put in place/announced YYYY-MM-DD format
- travel_restriction_date_end: date travel restriction lifted YYYY-MM-DD format
- strict_restrictions: does restriction include strict quarantine or travel ban? likley need to revisit this definition
- notes: description of travel restriction
- tr_source1: source url
- accessed_date1: date accessed url
- who_by1: inititials of person who accessed
- tr_source2: url of additional source
- accessed_date2: same as above
- who_by2: same as above

**Associated Projects:**

**Sources:** This comes from multiple online sources. They are cited in the dataset.
