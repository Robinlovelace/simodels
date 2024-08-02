#' Calculate flow using a pre-existing function
#'
#' Executes a spatial interaction model based on an OD data frame 
#' and user-specified function
#' 
#' @param od A data frame representing origin-destination data, e.g. as created by
#'   [si_to_od()]
#' @param fun A function that calculates the interaction (e.g. the number of trips)
#'   between each OD pair
#' @param constraint_production Character representing column in `od`.
#'   This argument, when set, ensures that the outputs are 'production constrained':
#'   the total 'interaction' (e.g. n. trips) for all OD pairs is set such that
#'   the total for each zone of origin cannot go above this value.
#' @param constraint_attraction Character representing column in `od`.
#'   This argument, when set, ensures that the outputs are 'attraction constrained':
#'   the total 'interaction' (e.g. n. trips) for all OD pairs is set such that
#'   the sum of trips to destination is equal to the mean value per destination.
#' @param constraint_total Single number representing the total interaction.
#'   This argument, when set, ensures that the sum of the interaction
#'   calculated will equal the value given.
#' @param ... Arguments passed to `fun`
#' @param output_col Character string containing the name of the new output
#'   column. `"interaction"` by default.
#' @return An sf data frame
#' @export
#' @importFrom rlang .data
#' @examples
#' od = si_to_od(si_zones, si_zones, max_dist = 4000)
#' fun_dd = function(d = "distance_euclidean", beta = 0.3) exp(-beta * d / 1000)
#' fun_dd(d = (1:5) * 1000)
#' od_dd = si_calculate(od, fun = fun_dd, d = distance_euclidean)
#' plot(od$distance_euclidean, od_dd$interaction)
#' fun = function(O, n, d, beta) O * n * exp(-beta * d / 1000)
#' od_output = si_calculate(od, fun = fun, beta = 0.3, O = origin_all, 
#'   n = destination_all, d = distance_euclidean)
#' head(od_output)
#' plot(od$distance_euclidean, od_output$interaction)
#' od_pconst = si_calculate(od, fun = fun, beta = 0.3, O = origin_all,
#'   n = destination_all, d = distance_euclidean, constraint_production = origin_all)
#' # Origin totals in OD data should equal origin totals in zone data
#' library(dplyr)
#' origin_totals_zones = od_pconst |>
#'   group_by(geo_code = O) |>
#'   summarise(all_od = sum(interaction)) |>
#'   sf::st_drop_geometry()
#' zones_joined = left_join(si_zones, origin_totals_zones)
#' plot(zones_joined$all, zones_joined$all_od)
#' plot(od_pconst$distance_euclidean, od_pconst$interaction)
#' plot(od_pconst["interaction"], logz = TRUE)
#' od_dd = si_calculate(od, fun = fun_dd, d = distance_euclidean, output_col = "res")
#' head(od_dd$res)
#' od_dd = si_calculate(od, fun = fun_dd, d = distance_euclidean, constraint_total = 10)
#' sum(od_dd$interaction)
si_calculate = function(
    od,
    fun,
    constraint_production,
    constraint_attraction,
    constraint_total,
    output_col = "interaction",
    ...
    ) {
  dots = rlang::enquos(...)
  od = dplyr::mutate(od, "{output_col}" := fun(!!!dots))
  if (!missing(constraint_production)) {
    od = constrain_production(od, output_col, {{constraint_production}})
  }
  if (!missing(constraint_attraction)) {
    od = constrain_attraction(od, output_col, {{constraint_attraction}})
  }
  if (!missing(constraint_total)) {
    od = constrain_total(od, output_col, constraint_total)
  }
  od
}
#' Predict spatial interaction based on pre-trained model
#' 
#' @param model A model object, e.g. from [lm()] or [glm()]
#' @inheritParams si_calculate
#' @seealso si_calculate
#' @return An sf data frame
#' @export 
#' @examples
#' od = si_to_od(si_zones, si_zones, max_dist = 4000)
#' m = lm(od$origin_all ~ od$origin_bicycle)
#' od_updated = si_predict(od, m)
si_predict = function(
    od,
    model,
    constraint_production,
    constraint_attraction,
    constraint_total,
    output_col = "interaction",
    ...
) {
  od[[output_col]] = stats::predict(model, od)
  if (!missing(constraint_production)) {
    od = constrain_production(od, output_col, {{constraint_production}})
  }
  if (!missing(constraint_attraction)) {
    od = constrain_attraction(od, output_col, {{constraint_attraction}})
  }
  if (!missing(constraint_total)) {
    od = constrain_total(od, output_col, constraint_total)
  }
  od
}

constrain_production = function(od, output_col, constraint_production) {
  # todo: should the grouping var (the first column, 1) be an argument?
  od_grouped = dplyr::group_by_at(od, 1)
  od_grouped = dplyr::mutate(
    od_grouped,
    "{output_col}" := .data[[output_col]] /
      sum(.data[[output_col]]) * dplyr::first( {{constraint_production}} )
  )
  # browser()
  # # Assert values are correct for test data:
  # od_grouped |>
  #   select({{constraint_production}}, interaction)
  # origin_totals = od_grouped |>
  #   sf::st_drop_geometry() |>
  #   sf::st_drop_geometry() |>
  #   # group_by(1) |>
  #   summarise(
  #     sum = sum(interaction),
  #     first = first({{constraint_production}})
  #   )
  # cor(origin_totals$sum, origin_totals$first)
  # # Test for york data:
  # zone_totals = left_join(
  #   zones_york |>
  #     sf::st_drop_geometry() |>
  #     rename(O = LSOA21CD) |>
  #     select(O, pupils_estimated),
  #   origin_totals
  # )

  
  
  od = dplyr::ungroup(od_grouped)
  od
}

constrain_attraction = function(od, output_col, constraint_attraction) {
  # todo: should the grouping var (the first column, 2) be an argument?
  od_grouped = dplyr::group_by_at(od, 2)
  od_grouped = dplyr::mutate(
    od_grouped,
    "{output_col}" := .data[[output_col]] /
      sum(.data[[output_col]]) * dplyr::first( {{constraint_attraction}} )
  )
}

constrain_total = function(od, output_col, constraint_total) {
  if(min(od[[output_col]]) < 0) {
    message("Negative values in output, setting them to zero")
    od[[output_col]][od[[output_col]] < 0] = 0
  }
  od[[output_col]] = od[[output_col]] / sum(od[[output_col]]) * constraint_total
  od
}
