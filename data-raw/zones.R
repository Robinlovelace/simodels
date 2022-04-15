## code to prepare `zones` dataset goes here
library(pct)
library(tidyverse)
zones = get_pct_zones(region = "west-yorkshire", geography = "msoa")
centroids = get_pct_centroids(region = "west-yorkshire", geography = "msoa")
zones = zones %>% 
  filter(lad_name == "Leeds")
centroids = centroids %>% 
  filter(lad_name == "Leeds")
usethis::use_data(zones, overwrite = TRUE)
usethis::use_data(centroids, overwrite = TRUE)

od_census = get_od()
od_census_min = od_census %>% 
  rename(O = geo_code1, D = geo_code2) %>% 
  filter(O %in% zones$geo_code & D %in% zones$geo_code)
usethis::use_data(od_census_min)
