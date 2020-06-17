##Download DXY html files

#' This script downloads and saves the daily printout of  https://ncov.dxy.cn/ncovh5/view/pneumonia
#' 
#' # set up libraries
library(httr)
library(xml2)
library(rvest)
library(here)

# set sub directory
setwd(here("china","China_casedata")) 

# save html 
url = "https://ncov.dxy.cn/ncovh5/view/pneumonia"
get_object = GET(url)
cat(content(get_object, "text"), file="temp.html")
html_object = read_html(url)
write_xml(html_object, file=paste0("dxy-html-archive/", substr(get_object$date, 1, 10), "_",
                                   substr(get_object$date,12,13), 
                                   substr(get_object$date,15,16),".html")) 
