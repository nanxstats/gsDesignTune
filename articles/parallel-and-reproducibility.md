# Parallel execution with future + reproducible reporting

`gsDesignTune` uses [future](https://future.futureverse.org) (via
[future.apply](https://future.apply.futureverse.org)) for parallel
evaluation. You control parallelism using
[`future::plan()`](https://future.futureverse.org/reference/plan.html);
`gsDesignTune` does not set a global plan.

``` r
library(gsDesign)
library(gsDesignTune)
library(future)
```

## Parallel run (example)

``` r
plan(multisession, workers = 2)

job <- gsSurvTune(
  k = 3,
  test.type = 4,
  alpha = 0.025,
  beta = 0.10,
  timing = tune_values(list(c(0.33, 0.67, 1), c(0.5, 0.75, 1))),
  hr = tune_seq(0.60, 0.75, length_out = 5),
  upper = SpendingFamily$new(
    SpendingSpec$new(sfLDOF, par = tune_fixed(0)),
    SpendingSpec$new(sfHSD, par = tune_seq(-4, 4, length_out = 5))
  ),
  lower = SpendingSpec$new(sfLDOF, par = tune_fixed(0)),
  lambdaC = log(2) / 6,
  eta = 0.01,
  gamma = c(2.5, 5, 7.5, 10),
  R = c(2, 2, 2, 6),
  T = 18,
  minfup = 6,
  ratio = 1
)

job$run(strategy = "grid", parallel = TRUE, seed = 1, cache_dir = "gstune_cache")
```

## Reproducible random search

``` r
plan(sequential)

job <- gsDesignTune(
  k = 3,
  test.type = 2,
  alpha = 0.025,
  beta = 0.10,
  timing = tune_values(list(c(0.33, 0.67, 1), c(0.5, 0.75, 1))),
  upper = SpendingFamily$new(
    SpendingSpec$new(sfLDOF, par = tune_fixed(0)),
    SpendingSpec$new(sfHSD, par = tune_seq(-4, 4, length_out = 5))
  )
)

job$run(strategy = "random", n = 5, parallel = FALSE, seed = 123)
head(job$results())
#>   upper_setting       timing upper_fun upper_par config_id status error_message
#> 1  function.... 0.5, 0.75, 1     sfHSD        -2         1     ok          <NA>
#> 2  function.... 0.5, 0.75, 1     sfHSD        -2         2     ok          <NA>
#> 3  function.... 0.5, 0.75, 1     sfHSD        -4         3     ok          <NA>
#> 4  function.... 0.33, 0.....     sfHSD        -2         4     ok          <NA>
#> 5  function.... 0.5, 0.75, 1     sfHSD         0         5     ok          <NA>
#>   warnings                        cache_key design_rds    call_args k test.type
#> 1     <NA> 9ea0d19ce1458f48c81bfc56c0a34190       <NA> 3, 2, 0..... 3         2
#> 2     <NA> 9ea0d19ce1458f48c81bfc56c0a34190       <NA> 3, 2, 0..... 3         2
#> 3     <NA> 503c551a1cf21057d81659eeb8483e68       <NA> 3, 2, 0..... 3         2
#> 4     <NA> ca4b397033e2751df9ef414c28e34e6b       <NA> 3, 2, 0..... 3         2
#> 5     <NA> ed750dfc7a5411194478dad66288c358       <NA> 3, 2, 0..... 3         2
#>   alpha beta          n_I final_n_I      upper_z      lower_z      upper_p
#> 1 0.025  0.1 0.523934....  1.047869 2.4717, .... -2.4717,.... 0.0067, ....
#> 2 0.025  0.1 0.523934....  1.047869 2.4717, .... -2.4717,.... 0.0067, ....
#> 3 0.025  0.1 0.509227....  1.018456 2.75, 2..... -2.75, -.... 0.003, 0....
#> 4 0.025  0.1 0.344287....  1.043295 2.6821, .... -2.6821,.... 0.0037, ....
#> 5 0.025  0.1 0.555438....  1.110878 2.2414, .... -2.2414,.... 0.0125, ....
#>        lower_p     power           en        upper_name        lower_name
#> 1 0.0067, .... 0.8999999 1.037208.... Hwang-Shih-DeCani Hwang-Shih-DeCani
#> 2 0.0067, .... 0.8999999 1.037208.... Hwang-Shih-DeCani Hwang-Shih-DeCani
#> 3 0.003, 0.... 0.9000000 1.012404.... Hwang-Shih-DeCani Hwang-Shih-DeCani
#> 4 0.0037, .... 0.9000000 1.033104.... Hwang-Shih-DeCani Hwang-Shih-DeCani
#> 5 0.0125, .... 0.9000000 1.093520.... Hwang-Shih-DeCani Hwang-Shih-DeCani
#>   bound_summary  final_n    max_n upper_z1 lower_z1
#> 1  c("IA 1:.... 1.047869 1.047869   2.4717  -2.4717
#> 2  c("IA 1:.... 1.047869 1.047869   2.4717  -2.4717
#> 3  c("IA 1:.... 1.018456 1.018456   2.7500  -2.7500
#> 4  c("IA 1:.... 1.043295 1.043295   2.6821  -2.6821
#> 5  c("IA 1:.... 1.110878 1.110878   2.2414  -2.2414
```

## Export a report

``` r
report_path <- tempfile(fileext = ".html")
job$report(report_path)
report_path
#> [1] "/tmp/RtmpymZdiu/file1ddc4a56dab3.html"
```
