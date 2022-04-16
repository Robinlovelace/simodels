## code to prepare `zones` dataset goes here
library(pct)
library(tidyverse)
zones = get_pct_zones(region = "west-yorkshire", geography = "msoa")
centroids = get_pct_centroids(region = "west-yorkshire", geography = "msoa")
si_zones = zones %>% 
  filter(lad_name == "Leeds") %>%
  select(1:13)
si_centroids = centroids %>% 
  filter(lad_name == "Leeds") %>%
  select(1:13)
usethis::use_data(si_zones, overwrite = TRUE)
usethis::use_data(si_centroids, overwrite = TRUE)

od_census = get_od()
si_od_census = od_census %>% 
  rename(O = geo_code1, D = geo_code2) %>% 
  filter(O %in% zones$geo_code & D %in% zones$geo_code)
usethis::use_data(si_od_census)
