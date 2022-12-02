library(tidyverse)
library(janitor)
library(qs)
library(sf)
library(tigris)
library(rleuven)

df <- qread('big_data/sod_1987_2021.qs') |> 
  select(br_id = uninumbr,
         br_num = brnum,
         yr = year,
         branch_deposits = depsumbr,
         established_date = sims_established_date,
         acquired_date = sims_acquired_date,
         branch_type = brsertyp,
         main_office = bkmo,
         bank_type = bkclass,
         address = addresbr,
         city = citybr,
         st = stalpbr,
         cty_fips = stcntybr,
         cty_name = cntynamb,
         lat = sims_latitude,
         inst_id = rssdid,
         inst_srvc = specgrp,
         inst_cty_fips = stcnty,
         inst_assets = asset,
         no_branches = unit,
         lon = sims_longitude)

qsave(df,'data/sod_clean.qs')

nrow(distinct(df,br_id))   # over 180K unique branch IDs
nrow(distinct(df,inst_id)) # over 21K unique institution IDs

# Map ---------------------------------------------------------------------
  
town <- places('OH',T,2018) |> filter(NAME == 'Chillicothe') |> 
  st_transform(6549) |> select(geometry)

town_rds <- roads('OH','Ross') |> 
  st_transform(6549) |> 
  st_intersection(town)

town_pts <- df |> 
  mutate(lat = as.numeric(lat),
         lon = as.numeric(lon),
         year = as.numeric(yr)) |> 
  filter(st == 'OH',
         not_na(lat),
         not_na(lon)) |> 
  st_as_sf(coords = c('lon','lat'), crs = 4326, remove = F) |> 
  st_transform(crs = 6549) |> 
  st_intersection(town) |> 
  group_by(br_id) |> 
  filter(year == max(year)) |> 
  ungroup()

ggplot() +
  geom_sf(data = town, color = 'black', size = .25, fill = 'gray90') +
  geom_sf(data = town_rds, color = 'black', size = .05) +
  geom_sf(data = town_pts, aes(fill = year), alpha = .7,
          size = 2, shape = 21, color = 'black') +
  scale_fill_gradient2(low = '#fe5c03', high = 'dodgerblue', name = 'Closure Year', 
                       mid = 'white', midpoint = 2005) +
  guides(fill = guide_colourbar(barheight = .5, barwidth = 12, title.position = 'top')) +
  labs(title = 'Historical Bank Branch Locations in Chillicothe, Ohio',
       caption = 'Source: FDIC Summary of Deposits, 2022
                  Note: darkest shade of blue indicates branch is still open') +
  theme_void(base_family = 'Avenir Next') +
  theme(plot.subtitle = element_text(hjust = 0.5), 
        plot.title = element_text(face = 'bold', hjust = 0.5, size = rel(1.5)), 
        legend.title = element_text(hjust = 0.5, face = 'bold'),
        legend.direction = 'horizontal',
        legend.position = 'bottom')

ggsave('plot/sod_example.jpg', dpi = 300, height = 8, width = 10)

