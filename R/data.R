#' Example zones and centroids
#'
#' `si_zones` and `si_centroids` represent administrative zones between which
#' flows are to be estimated.
#' @note The schema data can be (re-)generated using code in `data-raw`
#' @docType data
#' @keywords datasets
#' @name si_zones
#' @aliases si_centroids
#' @examples
#' si_zones
#' sf:::plot.sfg(si_zones$geometry)
#' sf:::plot.sfg(si_centroids$geometry, add = TRUE)
NULL

#' Example OD dataset
#'
#' Example OD dataset from the 2011 UK Census
#' @note Regenerate the data with scripts in the `data-raw` directory.
#'
#' @docType data
#' @keywords datasets
#' @name si_od_census
#' @examples
#' head(si_od_census)
NULL

#' Example destinations dataset: pubs in Leeds
#'
#' Example dataset from Leeds, UK
#' @note Regenerate the data with scripts in the `data-raw` directory.
#'
#' @docType data
#' @keywords datasets
#' @name si_pubs
#' @examples
#' head(si_pubs)
NULL

#' Example zones dataset: regions of Australia
#'
#' Example dataset from Australia
#' @note Regenerate the data with scripts in the `data-raw` directory.
#'
#' @docType data
#' @keywords datasets
#' @name zones_aus
#' @examples
#' head(zones_aus)
NULL

#' Example OD dataset: flows between regions in Australia
#'
#' Example dataset from Australia
#' @note Regenerate the data with scripts in the `data-raw` directory.
#'
#' @docType data
#' @keywords datasets
#' @name od_aus
#' @examples
#' head(od_aus)
NULL

#' Example zones dataset: administrative zones of York
#' 
#' See data-raw/zones_york.qmd for details on the data source.
#' 
#' @docType data
#' @keywords datasets
#' @name zones_york
#' @examples
#' head(zones_york)
#' sf:::plot.sfg(zones_york$geometry)
NULL

#' Example destinations dataset: schools in York
#' 
#' Example dataset from York, UK
#' 
#' See data-raw/zones_york.qmd for details on the data source.
#' 
#' @docType data
#' @keywords datasets
#' @name destinations_york
#' @examples
#' head(destinations_york)
NULL

#' Origin-Destination Data for Leeds
#' 
#' This dataset contains origin-destination data for Leeds, including the number of trips between output areas (OAs) and workplace zones (WPZs).
#' 
#' @docType data
#' @keywords datasets
#' @name si_oa_wpz
#' @examples
#' head(si_oa_wpz)
NULL

#' Origin Data for Leeds
#' 
#' This dataset contains the number of trips originating from each output area (OA) in Leeds.
#' 
#' @docType data
#' @keywords datasets
#' @name si_oa_wpz_o
#' @examples
#' head(si_oa_wpz_o)
#' sf:::plot.sf(si_oa_wpz_o["n_o"])
NULL

#' Destination Data for Leeds
#' 
#' This dataset contains the number of trips destined for each workplace zone (WPZ) in Leeds.
#' 
#' See [wicid.ukdataservice.ac.uk](https://wicid.ukdataservice.ac.uk/flowdata/cider/wicid/downloads.php) for details on the data source
#' and the file `data-raw/si_oa_wpz.qmd` in the package repo for details on how the example dataset was generated.
#' 
#' @docType data
#' @keywords datasets
#' @name si_oa_wpz_d
#' @examples
#' head(si_oa_wpz_d)
#' sf:::plot.sf(si_oa_wpz_d["n_d"])
NULL