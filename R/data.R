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
#' plot(si_zones$geometry)
#' plot(si_centroids$geometry, add = TRUE)
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
