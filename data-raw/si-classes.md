Using the simodels package with different input classes
================

``` r
# remotes::install_github("robinlovelace/simodels")
library(simodels)
# ?si_predict
```

``` r
od = si_to_od(si_zones, si_zones, max_dist = 4000)
#> 1695 OD pairs remaining after removing those with a distance greater than 4000 meters:
#> 15% of all possible OD pairs
m = lm(od$origin_all ~ od$origin_bicycle)
od_updated = si_predict(od, m)
class(od_updated)
#> [1] "sf"         "data.frame"
od_dt = data.table::data.table(od)
class(od_dt)
#> [1] "data.table" "data.frame"
od_updated_dt = si_predict(od_dt, m)
class(od_updated_dt)
#> [1] "data.table" "data.frame"
identical(od_updated$interaction, od_updated_dt$interaction)
#> [1] TRUE
```
