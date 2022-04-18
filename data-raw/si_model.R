# Aim: test different configurations for si_model/predict
devtools::load_all()
remotes::install_cran()

# What we have currently:
od = si_to_od(si_zones, si_zones, max_dist = 4000)
fun_dd = function(od, d = "distance_euclidean", beta = 0.3) exp(-beta * od[[d]] / 1000)
od_dd = si_calculate(od, fun = fun_dd)
plot(od$distance_euclidean, od_dd$res)
fun = function(od, O, n, d, beta) od[[O]] * od[[n]] * exp(-beta * od[[d]]/1000)
od_output = si_calculate(od, fun = fun, beta = 0.3, O = "origin_all", 
  n = "destination_all", d = "distance_euclidean")
head(od_output)
plot(od$distance_euclidean, od_output$res)
od_pconst = si_calculate(od, fun = fun, beta = 0.3, O = "origin_all", n = "destination_all",
  d = "distance_euclidean", var_p = origin_all)
plot(od_pconst$distance_euclidean, od_pconst$res)
plot(od_pconst["res"], logz = TRUE)
si_model = function(od, fun, var_p, ...) {
  od$res = fun(od, ...)
  if (!missing(var_p)) {
    od_grouped = dplyr::group_by(od, .data$O)
    od_grouped = dplyr::mutate(od_grouped, res = .data$res / sum(.data$res) * mean( {{var_p}} ))
    od = dplyr::ungroup(od_grouped)
  }
  od
}

# Option 1
od = si_to_od(si_zones, si_zones, max_dist = 4000)
fun_dd = function(d, beta = 0.3) exp(-beta * d / 1000)
od_dd = si_calculate(od, fun = fun_dd, d = distance_euclidean)
plot(od$distance_euclidean, od_dd$res)
fun = function(od, O, n, d, beta) od[[O]] * od[[n]] * exp(-beta * od[[d]]/1000)
od_output = si_calculate(od, fun = fun, beta = 0.3, O = "origin_all", 
  n = "destination_all", d = "distance_euclidean")
head(od_output)
plot(od$distance_euclidean, od_output$res)
od_pconst = si_calculate(od, fun = fun, beta = 0.3, O = "origin_all", n = "destination_all",
  d = "distance_euclidean", var_p = origin_all)
plot(od_pconst$distance_euclidean, od_pconst$res)
plot(od_pconst["res"], logz = TRUE)
si_model = function(od, fun, var_p, ...) {
  browser()
  res = fun(...)
  od = dplyr::mutate(od, res = fun(...))
  od$res = fun(od, ...)
  if (!missing(var_p)) {
    od_grouped = dplyr::group_by(od, .data$O)
    od_grouped = dplyr::mutate(od_grouped, res = .data$res / sum(.data$res) * mean( {{var_p}} ))
    od = dplyr::ungroup(od_grouped)
  }
  od
}


si_dd_exp = function(d, beta) {
  exp(d * -beta)
}

si_dd_exp(d = od$distance_euclidean, beta = 0.2)
dplyr::mutate(od,
 res = si_dd_exp(distance_euclidean, beta = 0.2)
 )

si_dd_exp = function(d, beta = 0.1) {
  exp({{d}} * -beta)
}

dplyr::mutate(od,
   res = si_dd_exp(distance_euclidean, beta = 0.2)
 )

si_model_tidy = function(od, fun, ...) {
  dplyr::mutate(res = fun(dplyr::vars(...)))
}

si_model_tidy(od, si_dd_exp, beta = 0.1, d = distance_euclidean)


f = flow ~ exp(distance_euclidean * -b)
f = as.formula(y ~ exp(distance_euclidean * -b))
with(od, f)
si_model_standard = function(od, fun, formula, output = "flow") {
  res = with(od, fun(...))
  res
}
si_model_standard(od)

si_dd_exp = function(d, beta = 0.1) {
  exp(d * -beta)
}


si_model_standard(od, si_dd_exp, beta = 0.2, d = "distance_euclidean")


