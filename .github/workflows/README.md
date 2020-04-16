# Description and timing of Github Actions

**china-dxy-update.yml**: Runs at 19:45 EST (23:45 UTC) daily. Runs `china/China_casedata/extract-dxy-case-counts.R`. Takes ~ 10 minutes to run.

**GDPH-daily-status-scrape.yml**: Runs at 12:00 EST (16:00 UTC) and 19:00 EST (23:00 EST) daily. Runs `georgia/ga_GDPH_daily_status_report/read_GDPH_daily_status_report.R`

**GDPH-daily-chart-scrape.yml**: Runs at 9:03 EST (1:03 UTC) daily. Uses Github Action in https://github.com/e3bo/ga-dph-covid-chart-scraper

**github-update.yml**: Runs at 8:00 EST (12:00 UTC). Runs `github_data_update.R`

**us-cases-wiki-scrape.yml**: Runs at 6:00 (10:00 UTC) and 22:00 (2:00 UTC) daily. Runs `US/US_wikipedia_cases_fatalities/read_UScases_wikipedia.R`


*Note*: Each action pulls, runs the script, and then pushes. Therefore actions cannot overlap as there will be merge conflicts that cause the action to fail.
