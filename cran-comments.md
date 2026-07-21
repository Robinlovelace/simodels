Patch release to fix a bug in `constrain_attraction()` and `constrain_total()`.

## R CMD check results

0 errors | 0 warnings | 0 notes

* Fixed: `constrain_total()` referenced a non-existent `od_grouped` variable (copy-paste bug)
* Fixed: `constrain_attraction()` now correctly ungroups result to match `constrain_production()` (#45)
