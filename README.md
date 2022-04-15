<!-- badges: start -->

[![R-CMD-check](https://github.com/robinlovelace/si/workflows/R-CMD-check/badge.svg)](https://github.com/robinlovelace/si/actions)
<!-- badges: end -->

The goal of {si} is to demonstrate Spatial Interaction models from first
principles (see the [`sims`
vignette](https://robinlovelace.github.io/si/articles/sims.html) for a
more detailed description of SIMs and implementation in R without using
this package for reference). The package also contains reproducible code
and documentation demonstrating how they work.

Spatial Interaction Models (SIMs) estimate movement between spatial
entities. They have been central to transport modelling since the 1960s,
with many refinements over the
[decades](https://www.researchgate.net/publication/284345182_Forecasting_urban_travel_Past_present_and_future).
There are four main
[types](https://doi.org/10.1016/j.jtrangeo.2015.12.008) of traditional
SIM:

-   Unconstrained
-   Production-constrained
-   Attraction-constrained
-   Doubly-constrained

The focus of this package is currently on unconstrained and
production-constrained SIMs.

<!-- # Implementations in other languages -->

## si basics

Install the package as follows:

``` r
install.packages("remotes") # if not already installed
```

``` r
remotes::install_github("robinlovelace/si")
```

    Skipping install of 'si' from a github remote, the SHA1 (ee3925f5) has not changed since last install.
      Use `force = TRUE` to force installation

Run a basic SIM as follows:

``` r
library(si)
od = si_to_od(origins = zones, destinations = zones, max_euclidean_distance = 5000)
```

    2505 OD pairs remaining after removing those with a distance greater than 5000 meters:
    22 of all possible OD pairs

``` r
gravity_model = function(od, beta) {
  od[["origin_all"]] * od[["destination_all"]] *
    exp(-beta * od[["distance_euclidean"]] / 1000)
} 
od_res = si_model(od, fun = gravity_model, beta = 0.3, var_p = origin_all)
plot(od_res$distance_euclidean, od_res$res)
```

![](man/figures/README-distance%20plot-1.png)

What just happened? As the example above shows, the package
allows/encourages you to define and use your own functions to estimate
the amount of interaction/movement between places. The resulting
estimates of interaction, returned in the column `res` and plotted with
distance in the graphic above, resulted from our choice of spatial
interaction model inputs, allowing a wide range of alternative
approaches to be implemented. This flexibility is a key aspect of the
package, enabling small and easily modified functions to be implemented
and tested.

The output `si_model()` is a geographic object which can be plotted as a
map:

``` r
plot(od_res["res"], logz = TRUE)
```

![](man/figures/README-map-1.png)

Perhaps the most important function in the package is therefore
`si_to_od()`, which transforms geographic entities (typically zones but
points and other geographic features could be used) into a data frame
representing the full combination of origin-destination pairs that are
less than `max_euclidean_distance` meters apart. A common saying in data
science is that 80% of the effort goes into the pre-processing stage.
This is equally true for spatial interaction modelling as it is for
other types of data intensive analysis/modelling work. So what does this
function return?

``` r
names(od)
```

     [1] "O"                         "D"                        
     [3] "ox"                        "oy"                       
     [5] "dx"                        "dy"                       
     [7] "distance_euclidean"        "origin_geo_name"          
     [9] "origin_lad11cd"            "origin_lad_name"          
    [11] "origin_all"                "origin_bicycle"           
    [13] "origin_foot"               "origin_car_driver"        
    [15] "origin_car_passenger"      "origin_motorbike"         
    [17] "origin_train_tube"         "origin_bus"               
    [19] "origin_taxi_other"         "destination_geo_name"     
    [21] "destination_lad11cd"       "destination_lad_name"     
    [23] "destination_all"           "destination_bicycle"      
    [25] "destination_foot"          "destination_car_driver"   
    [27] "destination_car_passenger" "destination_motorbike"    
    [29] "destination_train_tube"    "destination_bus"          
    [31] "destination_taxi_other"    "geometry"                 

As shown in the output above, the function allows you to use any
variable in the origin or destination data in the function, with column
names appended with `origin` and `destination`.

Note: support for OD datasets in which the origins and destinations are
different objects is work in progress (see
[\#3](https://github.com/Robinlovelace/si/issues/3)).

## Feedback

We would be interested to hear how the approach presented in this
package compared with other implementations such as those presented in
the links below. If anyone would like to try the approach or implement
it in another language feel free to get in touch via the issue tracker.

## Alternative approaches

The {si} package is nascent. Anyone looking for more mature approaches
could check the following:

-   Reproducible [code](https://rpubs.com/adam_dennett/257231)
    implementing SIMs in R by Adam Dennet, based on the outdated `sp`
    class system, and based on [`sf`
    classes](https://github.com/adamdennett/LondonSchoolsSIM/blob/main/Schools.Rmd)

-   The [`spflow` R package](https://github.com/LukeCe/spflow) on CRAN

-   The [`spint` Python
    package](https://spint.readthedocs.io/en/latest/)
