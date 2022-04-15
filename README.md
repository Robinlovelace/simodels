<!-- badges: start -->

[![R-CMD-check](https://github.com/robinlovelace/si/workflows/R-CMD-check/badge.svg)](https://github.com/robinlovelace/si/actions)
<!-- badges: end -->

The goal of {si} is to demonstrate Spatial Interaction models from first
principles (see the `sims` vignette for a more detailed description of
SIMs and implementation in R without using this package for reference).
The package also contains reproducible code and documentation
demonstrating how they work.

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

# <span class="header-section-number">1</span> Implementations in other languages

We would be interested to hear how the approach presented in this
package compared with other implementations such as those presented in
the links below. If anyone would like to try the approach or implement
it in another language feel free to get in touch via the issue tracker.

# <span class="header-section-number">2</span> Resources

-   Reproducible [code](https://rpubs.com/adam_dennett/257231)
    implementing SIMs in R by Adam Dennet, based on the outdated `sp`
    class system, and based on [`sf`
    classes](https://github.com/adamdennett/LondonSchoolsSIM/blob/main/Schools.Rmd)

-   The [`spflow` R package](https://github.com/LukeCe/spflow) on CRAN

-   The [`spint` Python
    package](https://spint.readthedocs.io/en/latest/)
