## worldCases
Stores data read from wikipedia on the cumulative number of cases in a country. Extracted manually until March 15th on [this sheet](https://docs.google.com/spreadsheets/d/1SC28cM52m6s1gTJutpvFxadT9GGu-li90tsqkGuaM48/edit#gid=770412370). After March 15th scraped each day by running `get-world-data.Rmd`to
extract data from [2020 coronavirus pandemic wiki page](https://en.wikipedia.org/wiki/2019%E2%80%9320_coronavirus_pandemic) and adds the current day to the dataset. Must be run every day at ~10 PM or extracted from archived pages on wayback machine. Wikipedia does not store these data by date so running daily at the same time is necessary to keep data current and accurate.

<b>Metadata:</b> </br>
 Column name description of data file:
 - `Date`: Date of cumulative case record
 - `Country`: Country name
 - `Cases`: cumulative number of cases for `Country` on `Date`

<b>Related subdirectory and/or files</b>
- `get-world-data.Rmd`
- worldCases.csv

<b>Projects</b>
- TBD
