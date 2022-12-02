library(tidyverse)
library(haven)
library(rleuven)

read_sod <- function(year){
  filename <- sprintf('big_data/sod/csv/ALL_%s.csv',year)
  data.table::fread(filename, colClasses = 'character', data.table = FALSE) |>
    janitor::clean_names()}

df <- map_df(.x = 1987:2021,
             .f = function(x){read_sod(x)})

qs::qsave(df,'big_data/sod_1987_2021.qs')