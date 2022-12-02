library(tidyverse)
library(haven)
library(rleuven)

pull_sod <- function(year){
  url <- sprintf('https://www7.fdic.gov/sod/ShowFileWithStats1.asp?strFileName=ALL_%s.zip',year)
  location <- sprintf('big_data/sod/sod_%s.zip',year)
  download.file(url,location)}

pull_sod2 <- function(year){
  url <- sprintf('https://www.fdic.gov/foia/sod/soddata/csv/sod-%s.zip',year)
  location <- sprintf('big_data/sod/sod_%s.zip',year)
  download.file(url,location)}

map(.x = 1994:2021, .f = function(x){pull_sod(x)})
beepr::beep()

map(.x = 1987:1993, .f = function(x){pull_sod2(x)})
beepr::beep()

# unzip everything and put each 'ALL_YYYY.csv' in 'big_data/sod/csv' folder
