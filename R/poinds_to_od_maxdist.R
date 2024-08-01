#' COnvert points to OD with a maxiumum distance
#'
#' 
#' @param p A spatial points object or a matrix of coordinates representing points
#' @param pd Optional spatial points object or matrix objects representing destinations
#' @param max_dist Maximum distance in metres
#' @param max_dest The maximum number of destinations for each origin (numeric).
#'   Default is Inf. Alternative to max_dist for limiting the number of ODs.
#' @param intrazonal Should the result only include interzonal OD pairs, in which
#' the ID of the origin is different from the ID of the destination zone?
#' `FALSE` by default
#' @param ids_only Should a data frame with only 2 columns (origin and destination IDs)
#' be returned? The default is `FALSE`, meaning the result should also contain the
#' coordinates of the start and end points of each OD pair.
#' @return An sf data frame
#' @export

points_to_od_maxdist = function(p, pd = NULL, max_dist = Inf, max_dest = Inf, intrazonal = FALSE, ids_only = FALSE){
  
  if(any(sf::st_geometry_type(p) != "POINT")){
    message("Converting to centroids")
    suppressWarnings(p <- sf::st_centroid(p))
  }
  
  if(!is.null(pd)){
    if(any(sf::st_geometry_type(pd) != "POINT")){
      suppressWarnings(pd <- sf::st_centroid(pd))
    }
  } else {
    pd = p
  }
  
  if(max_dest > nrow(pd)){
    max_dest = nrow(pd)
  }
  
  nn <- nngeo::st_nn(p, pd, k = max_dest, maxdist = max_dist, returnDist = TRUE)
  res = data.frame(O = rep(p[[1]], lengths(nn$nn)),
                   D = pd[[1]][unlist(nn$nn, use.names = FALSE)],
                   distance_euclidean = unlist(nn$dist, use.names = FALSE))
  
  if(intrazonal){
    res = res[res$O != res$D,]
  }
  
  if(ids_only){
    return(res)
  }
  
  # Add Coords
  p_coords = as.data.frame(sf::st_coordinates(p))
  names(p_coords) = c("X1","Y1")
  
  pd_coords = as.data.frame(sf::st_coordinates(pd))
  names(pd_coords) = c("X2","Y2")
  
  res = cbind(res, p_coords[match(res$O, p[[1]]),])
  res = cbind(res, pd_coords[match(res$D, pd[[1]]),])
  res
}
