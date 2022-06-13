## code to prepare `zones` dataset goes here
library(pct)
library(tidyverse)
library(tmap)
tmap_mode("view")
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
  filter(O %in% si_zones$geo_code & D %in% si_zones$geo_code)
usethis::use_data(si_od_census, overwrite = TRUE)

# Get pubs in Leeds
source("https://github.com/cyipt/actdev/raw/main/code/get_pois.R")
q = "SELECT * FROM 'points' WHERE amenity IN ('pub')"
pubs_west_yorkshire = get_pois(region_name = "west yorkshire", q = q)
pubs_leeds = pubs_west_yorkshire[sim::si_zones, ]
plot(pubs_leeds)
si_pubs = pubs_leeds %>% 
  select(-other_tags)
usethis::use_data(si_pubs)
