library(here)
ksource <- function(x, ...) {
  source(knitr::purl(x, output = tempfile()), ...)
}

ksource(here("code/logistic_regression.Rmd"))
ksource(here("code/random_forest.Rmd"))
ksource(here("code/lightgbm.Rmd"))
ksource(here("report/report.Rmd"))

