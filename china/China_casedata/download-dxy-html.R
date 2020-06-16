##Download DXY html files

#' This script downloads and saves the daily printout of  https://ncov.dxy.cn/ncovh5/view/pneumonia
#' 
#' # set up libraries
library(httr)
library(xml2)
library(rvest)
library(stringr)
library(here)

# set sub directory
setwd(here("china","China_casedata")) 

# save html 
url = "https://ncov.dxy.cn/ncovh5/view/pneumonia"
get_object = GET(url)
cat(content(get_object, "text"), file="temp.html")
html_object = read_html(url)
write_xml(html_object, file=paste("dxy-html-archive/",
                                  str_sub(get_object$headers$date, 6, 7),
                                  toupper(str_sub(get_object$headers$date, 9, 11)),
                                  str_sub(get_object$headers$date, 18, 19),
                                  str_sub(get_object$headers$date, 21, 22),
                                  ".html",sep = "")) 
