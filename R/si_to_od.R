#' Prepare OD data frame
#'
#' Prepares an OD data frame that next could be used to estimate movement
#' between origins and destinations with a spatial interaction model.
#'
#' In most origin-destination datasets the spatial entities that constitute
#' origins (typically administrative zones) also represent destinations. In this
#' 'unipartite' case `origins` and `destinations` should be passed the same
#' object, an `sf` data frame representing administrative zones.
#'
#' 'Bipartite' datasets, by contrast, represent "spatial interaction systems
#' where origins cannot act as destinations and vice versa" (Hasova et al.
#' [2022](https://lenkahas.com/files/preprint.pdf)).
#'
#' a different `sf` object can be passed to the `destinations` argument.
#'
#' @param origins `sf` object representing origin locations/zones
#' @param destinations `sf` object representing destination locations/zones
#' @param max_dist Euclidean distance in meters (numeric). Only OD pairs that
#'   are this distance apart or less will be returned and therefore included in
#'   the SIM.
#' @param max_dest The maximum number of destinations for each origin (numeric).
#'   Default is Inf. Alternative to max_dist for limiting the number of ODs.
#' @param intrazonal Include intrazonal OD pairs? Intrazonal OD pairs represent
#'   movement from one place in a zone to another place in the same zone. `TRUE`
#'   by default.
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

si_to_od = function(origins, destinations, max_dist = 10000, max_dest = Inf, intrazonal = TRUE) {
  
  od_df = points_to_od_maxdist(origins, destinations, max_dist = max_dist, intrazonal = intrazonal, max_dest = max_dest)
  
  #message("Hi")
  od_sfc = od::odc_to_sfc(od_df[3:6])
  sf::st_crs(od_sfc) = 4326 # todo: add CRS argument?
  od_df = od_df[-c(3:6)]
  #message("Hi2")
  # join origin attributes
  origins_to_join = sf::st_drop_geometry(origins)
  names(origins_to_join) = paste0("origin_", names(origins_to_join))
  names(origins_to_join)[1] = names(od_df)[1]
  od_dfj = dplyr::inner_join(od_df, origins_to_join, by = "O")
  #message("Hi3")
  # join destination attributes
  destinations_to_join = sf::st_drop_geometry(destinations)
  names(destinations_to_join) = paste0("destination_", names(destinations_to_join)) # nolint
  names(destinations_to_join)[1] = names(od_df)[2]
  od_dfj = dplyr::inner_join(od_dfj, destinations_to_join, by = "D")
  #message("Hi4")
  # names(od_dfj)
  # create and return sf object
  sf::st_sf(od_dfj, geometry = od_sfc)
}
