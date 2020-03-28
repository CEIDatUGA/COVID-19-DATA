## GHSI_2019
These data are taken from the global health security index website: https://www.ghsindex.org/. The GHSI is an expert derived metric of epidemic preparedness by country based on ~140 variables condensed into 8 categories and 1 overall score. These two sheets include all of those data.

<b>Metadata:</b> 

These files have a nested naming structure of their columns:
OVERALL SCORE: overall score (0-100)
1): Top level score category (0-100)
1.1): Subcategory score (0-100)
1.1.1) Sub-subcategory score (0-100)
1.1.1a) Underlying indicator variable (range and units vary)

All column titles are detailed and descriptive but see https://www.ghsindex.org/ for additional details. For some indicator columns units are unclear. It will take a good bit of sleuthing to track all these down (likely on a mac or pc) but we can do that if the underlying indicators are likely to be widely used.

`GHSI_2019_Indicators.csv` : Rows represent countries. Columns represent indicators used to calculate scores. Empty columns are left for all scores and indicators only are shown.

`GHSI_2019_Scores.csv` : Rows represent countries. Columns represent scores. Empty columns are left for indicators and scores only are shown.
 
<b>Related subdirectory and/or files</b>

<b>Projects</b>
List/Link related projects