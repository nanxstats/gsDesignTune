# Parallel evaluation and reproducible reporting

gsDesignTune uses {future} (via {future.apply}) for parallel evaluation.
You control parallelism using
[`future::plan()`](https://future.futureverse.org/reference/plan.html);
gsDesignTune does not set a global plan.

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
job$table()
```

| Config ID | Upper parameter | Timing        | Final N | Power | Upper Z (IA1) | Lower Z (IA1) |
|-----------|-----------------|---------------|---------|-------|---------------|---------------|
| 1         | -2              | 0.5, 0.75, 1  | 1.05    | 0.9   | 2.47          | -2.47         |
| 2         | -2              | 0.5, 0.75, 1  | 1.05    | 0.9   | 2.47          | -2.47         |
| 3         | -4              | 0.5, 0.75, 1  | 1.02    | 0.9   | 2.75          | -2.75         |
| 4         | -2              | 0.33, 0.67, 1 | 1.04    | 0.9   | 2.68          | -2.68         |
| 5         | 0               | 0.5, 0.75, 1  | 1.11    | 0.9   | 2.24          | -2.24         |

## Export a report

``` r
report_path <- tempfile(fileext = ".html")
job$report(report_path)
report_path
#> [1] "/tmp/RtmpSbfbzG/file1cdd5450d33b.html"
```
