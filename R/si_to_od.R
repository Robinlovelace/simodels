#' Prepare OD data frame
#'
#' Prepares an OD data frame that next could be used to
#' estimate movement between origins and destinations 
#' with a spatial interaction model.
#' 
#' In most origin-destination datasets the spatial entities that constitute
#' origins (typically administrative zones) also represent destinations.
#' In this 'unipartite' case `origins` and `destinations` should be passed
#' the same object, an `sf` data frame representing administrative zones.
#' 
#' 'Bipartite' datasets, by contrast, represent
#' "spatial interaction systems where origins cannot act as
#' destinations and vice versa" (Hasova et al. [2022](https://lenkahas.com/files/preprint.pdf)). 
#' 
#'  a different
#' `sf` object can be passed to the `destinations` argument.
#' 
#' @param origins `sf` object representing origin locations/zones
#' @param destinations `sf` object representing destination locations/zones
#' @param max_dist Euclidean distance in meters (numeric).
#'   Only OD pairs that are this distance apart or less will be returned
#'   and therefore included in the SIM.
#' @param intrazonal Include intrazonal OD pairs?
#'   Intrazonal OD pairs represent movement from one
#'   place in a zone to another place in the same zone.
#'   `TRUE` by default.
#' @return An sf data frame
#' @export
#' @examples
#' library(sf)
#' origins = si_centroids[c(1, 2, 99), ]
#' destinations = origins
#' plot(origins$geometry)
#' odsf = si_to_od(origins, destinations, max_dist = 1200)
#' plot(odsf)
#' # note: result contains intrazonal flows represented by linestrings
#' # with a length of 0, e.g.:
#' sf::st_coordinates(odsf$geometry[1])
#' # With different destinations compared with origins
#' library(sf)
#' origins = si_centroids[c(2, 99), c(1, 6, 7)]
#' destinations = si_centroids[1, c(1, 6, 8)]
#' odsf = si_to_od(origins, destinations)
#' nrow(odsf) # no intrazonal flows
#' plot(odsf)
si_to_od = function(origins, destinations, max_dist = Inf, intrazonal = TRUE) {
  if(identical(origins, destinations)) {
    od_df = od::points_to_od(origins)
  } else {
    od_df = od::points_to_od(origins, destinations)
  }
  od_df$distance_euclidean = geodist::geodist(
    x = od_df[c("ox", "oy")],
    y = od_df[c("dx", "dy")],
    paired = TRUE
  )
  # Max dist check
  if(max(od_df$distance_euclidean) > max_dist) {
    nrow_before = nrow(od_df)
    od_df = od_df[od_df$distance_euclidean <= max_dist, ]
    nrow_after = nrow(od_df)
    pct_kept = round(nrow_after / nrow_before * 100)
    message(
      nrow_after,
      " OD pairs remaining after removing those with a distance greater than ", # nolint
      max_dist, " meters", ":\n",
      pct_kept, "% of all possible OD pairs"
    )
  }
  
  # Intrazonal check
  if(!intrazonal){
    od_df = dplyr::filter(od_df, distance_euclidean > 0)
  }
  
  od_sfc = od::odc_to_sfc(od_df[3:6])
  sf::st_crs(od_sfc) = 4326 # todo: add CRS argument?
  od_df = od_df[-c(3:6)]
  
  # join origin attributes
  origins_to_join = sf::st_drop_geometry(origins)
  names(origins_to_join) = paste0("origin_", names(origins_to_join))
  names(origins_to_join)[1] = names(od_df)[1]
  od_dfj = dplyr::inner_join(od_df, origins_to_join, by = "O")
  # join destination attributes
  destinations_to_join = sf::st_drop_geometry(destinations)
  names(destinations_to_join) = paste0("destination_", names(destinations_to_join)) # nolint
  names(destinations_to_join)[1] = names(od_df)[2]
  od_dfj = dplyr::inner_join(od_dfj, destinations_to_join, by = "D")
  # names(od_dfj)
  # create and return sf object
  sf::st_sf(od_dfj, geometry = od_sfc)
}
