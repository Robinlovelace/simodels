#' Prepare OD
#'
#' Prepares an OD data frame that next could be used to
#' estimate movement between origins and destinations 
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
  od_dfj = dplyr::inner_join(od_df, origins_to_join, by = "O")
  # join destination attributes
  destinations_to_join = sf::st_drop_geometry(destinations)
  names(destinations_to_join) = paste0("destination_", names(destinations_to_join)) # nolint
  names(destinations_to_join)[1] = names(od_df)[2]
  od_dfj = dplyr::inner_join(od_dfj, destinations_to_join, by = "D")
  names(od_dfj)

  # convert to sfc:

  od_sfc = od::odc_to_sfc(od_df[3:6])
  sf::st_crs(od_sfc) = 4326 # todo: add CRS argument?
  # create and return sf object
  sf::st_sf(od_dfj, geometry = od_sfc)
}

#' Run a spatial interaction model
#'
#' Executes a spatial iteraction model based on an OD data frame 
#' and user-specified function
#' 
#' @param od A data frame representing origin-destination data, e.g. as created by
#'   [si_to_od()]
#' @param fun A function that calculates the interaction (e.g. the number of trips)
#'   between each OD pair
#' @param var_p Use this argument to run a 'production constrained' SIM.
#'   Character string corresponding to column in the `od`
#'   dataset that constrains the total 'interaction' (e.g. n. trips) for all OD pairs
#'   such that the total for each zone of origin cannot go above this value.
#' @param ... Arguments passed to `fun`
#' @export
#' @importFrom rlang .data
#' @examples
#' od = si_to_od(zones, zones)
#' fun_dd = function(od, d = "distance_euclidean", beta = 0.3) exp(-beta * od[[d]] / 1000)
#' od_dd = si_model(od, fun = fun_dd)
#' plot(od$distance_euclidean, od_dd$res)
#' fun = function(od, O, n, d, beta) od[[O]] * od[[n]] * exp(-beta * od[[d]]/1000)
#' od_output = si_model(od, fun = fun, beta = 0.3, O = "origin_all", 
#'   n = "destination_all", d = "distance_euclidean")
#' head(od_output)
#' plot(od$distance_euclidean, od_output$res)
#' od_pconst = si_model(od, fun = fun, beta = 0.3, O = "origin_all", n = "destination_all",
#'   d = "distance_euclidean", var_p = origin_all)
#' plot(od_pconst$distance_euclidean, od_pconst$res)
#' plot(od_pconst["res"], logz = TRUE)
si_model = function(od, fun, var_p, ...) {
    od$res = fun(od, ...)
    if (!missing(var_p)) {
        od_grouped = dplyr::group_by(od, .data$O)
        od_grouped = dplyr::mutate(od_grouped, res = .data$res / sum(.data$res) * mean( {{var_p}} ))
        od = dplyr::ungroup(od_grouped)
    }
    od
}
