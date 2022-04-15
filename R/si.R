#' Spatial Interaction Model
#'
#' Estimate movement between origins and destinations 
#' with a spatial interaction model
#'
#' @param origins `sf` object representing origin locations/zones
#' @param destinations `sf` object representing destination locations/zones
#' @param max_euclidean_distance Maximum distance in meters between OD pairs.
#'   Only OD pairs that are this distance apart or less will be returned.
#' @export
#' @examples
#' origins = centroids
#' destinations = centroids
#' odsf = si_to_od(origins, destinations)
#' plot(odsf)
#' 
si_to_od = function(origins, destinations, max_euclidean_distance = 10000) {
  if(!identical(origins, destinations)) {
        stop("Origins and destinations are different, not implemented yet")
    }
  od_df = od::points_to_od(origins)
  od_df$distance_euclidean = geodist::geodist(
      x = od_df[c("ox", "oy")],
      y = od_df[c("dx", "dy")],
      paired = TRUE
      )
  if(max(od_df$distance_euclidean) > max_euclidean_distance) {
      nrow_before = nrow(od_df)
      od_df = od_df[od_df$distance_euclidean <= max_euclidean_distance, ]
      nrow_after = nrow(od_df)
      pct_kept = round(nrow_after / nrow_before * 100)
      message(
          nrow_after,
          " OD pairs remaining after removing those with a distance greater than ", # nolint
          max_euclidean_distance, " meters", ":\n",
          pct_kept, " of all possible OD pairs"
          )
  }
  # join origin attributes
  origins_to_join = sf::st_drop_geometry(origins)
  names(origins_to_join) = paste0("origin_", names(origins_to_join))
  names(origins_to_join)[1] = names(od_df)[1]
  od_dfj = dplyr::inner_join(od_df, origins_to_join)
  # join destination attributes
  destinations_to_join = sf::st_drop_geometry(destinations)
  names(destinations_to_join) = paste0("destination_", names(destinations_to_join)) # nolint
  names(destinations_to_join)[1] = names(od_df)[2]
  od_dfj = dplyr::inner_join(od_dfj, destinations_to_join)
  names(od_dfj)

  # convert to sfc:

  od_sfc = od::odc_to_sfc(od_df[3:6])
  sf::st_crs(od_sfc) = 4326 # todo: add CRS argument?
  # create and return sf object
  sf::st_sf(od_dfj, geometry = od_sfc)
}

