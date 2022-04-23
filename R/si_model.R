#' Calculate flow using a pre-existing function
#'
#' Executes a spatial interaction model based on an OD data frame 
#' and user-specified function
#' 
#' @param od A data frame representing origin-destination data, e.g. as created by
#'   [si_to_od()]
#' @param fun A function that calculates the interaction (e.g. the number of trips)
#'   between each OD pair
#' @param constraint_p Use this argument to run a 'production constrained' SIM.
#'   Character string corresponding to column in the `od`
#'   dataset that constrains the total 'interaction' (e.g. n. trips) for all OD pairs
#'   such that the total for each zone of origin cannot go above this value.
#' @param ... Arguments passed to `fun`
#' @param output_col Character string containing the name of the new output
#'   column. `"interaction"` by default.
#' @export
#' @importFrom rlang .data
#' @examples
#' od = si_to_od(si_zones, si_zones, max_dist = 4000)
#' fun_dd = function(d = "distance_euclidean", beta = 0.3) exp(-beta * d / 1000)
#' fun_dd(d = (1:5)*1000)
#' od_dd = si_calculate(od, fun = fun_dd, d = distance_euclidean)
#' plot(od$distance_euclidean, od_dd$interaction)
#' fun = function(O, n, d, beta) O * n * exp(-beta * d / 1000)
#' od_output = si_calculate(od, fun = fun, beta = 0.3, O = origin_all, 
#'   n = destination_all, d = distance_euclidean)
#' head(od_output)
#' plot(od$distance_euclidean, od_output$interaction)
#' od_pconst = si_calculate(od, fun = fun, beta = 0.3, O = origin_all,
#'   n = destination_all, d = distance_euclidean, constraint_p = origin_all)
#' plot(od_pconst$distance_euclidean, od_pconst$interaction)
#' plot(od_pconst["interaction"], logz = TRUE)
#' od_dd = si_calculate(od, fun = fun_dd, d = distance_euclidean, output_col = "res")
#' head(od_dd$res)
si_calculate = function(od, fun, constraint_p, ..., output_col = "interaction") {
  dots = rlang::enquos(...)
  od = dplyr::mutate(od, {{output_col}} := fun(!!!dots))
  if (!missing(constraint_p)) {
    od_grouped = dplyr::group_by(od, .data$O)
    od_grouped = dplyr::mutate(
      od_grouped,
      output_col = .data[[output_col]] /
        sum(.data[[output_col]]) * mean( {{constraint_p}} )
      )
    od = dplyr::ungroup(od_grouped)
  }
  od
}
#' Predict si model based on pre-trained model
#' 
#' @param model A model object, e.g. from [lm()] or [glm()]
#' @inheritParams si_calculate
#' @seealso si_calculate
#' @export 
#' @examples
#' od = si_to_od(si_zones, si_zones, max_dist = 4000)
#' m = lm(od$origin_all ~ od$origin_bicycle)
#' od_updated = si_predict(od, m)
si_predict = function(od, model, constraint_p, output_col = "interaction") {
  od[[output_col]] = stats::predict(model, od)
  if (!missing(constraint_p)) {
    od_grouped = dplyr::group_by(od, .data$O)
    od_grouped = dplyr::mutate(
      od_grouped,
      interaction = .data[[output_col]] /
        sum(.data[[output_col]]) * mean( {{constraint_p}} )
      )
    od = dplyr::ungroup(od_grouped)
  }
  od
}
