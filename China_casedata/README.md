
### China Data 
Data manager: Anna Willoughby 

Chinese prefecture and province case data are accessd from the [丁香园 website](https://3g.dxy.cn/newh5/view/pneumonia?scene=2&clicktime=1579579384&enterid=1579579384&from=groupmessage&isappinstalled=0) nightly ~6 pm - 12 pm EST. 丁香园 is an online forum for medical related news and medical professionals. This website was built to disseminate information on the confirmed coronavirus cases with information being supplied directly from the China National Health Commission and the corresponding health commission in each province. Further details data collation on 丁香园 can be found [here](https://docs.google.com/document/d/1thhxR-dWp61cVDQUhzcU2sTMt5oAXI0Q8IxaRFFcWP0/edit?usp=sharing).

These data are currently being used the following projects: 
   - [Early Intervention](https://github.com/CEIDatUGA/ncov-early-intervention)
   - [Spatial spread in China](https://github.com/CEIDatUGA/CoronavirusSpatial)

#### Listing of files 
```
├─ dxy_data/
|	├── clean-daily-tables                          | daily extracted tables from html in csv format
|	├── prefecture_casecounts_preJan23.csv          | prefecture case occurence by date manually curated from start of outbreak through January 23rd from news articles and government reports
|	├── prefecture_master_binary.csv                | binary prefecture case occurence by date
|	├── prefecture_master.csv                       | master file of case counts by prefecture
|	├── province_master.csv                         | master file of case counts by province
|	└── spatial/
|	   ├── shapefile_adm2_modified.csv              | ADM2 spatial taxonomy with synonymized chinese characters 
|	   ├── prefecture_adm.csv                       | ADM2 GADM names          
|	   └── province_adm.csv                         | ADM1 GADM names          

├─ dxy-html-archive/                               | folder with archived html files since January 23, 2020
└─ extract-dxy-case-counts.R                       | R script to process raw html files 
