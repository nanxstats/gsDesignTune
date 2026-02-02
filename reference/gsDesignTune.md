# Create a tune job for `gsDesign::gsDesign()`

`gsDesignTune()` is a drop-in replacement for
[`gsDesign::gsDesign()`](https://keaven.github.io/gsDesign/reference/gsDesign.html)
that returns a tune job object instead of immediately running a single
design.

## Usage

``` r
gsDesignTune(..., upper = NULL, lower = NULL)
```

## Arguments

- ...:

  Arguments to
  [`gsDesign::gsDesign()`](https://keaven.github.io/gsDesign/reference/gsDesign.html).
  Any argument can be replaced by a `tune_*()` specification.

- upper, lower:

  Optional spending specifications provided as `SpendingSpec` or
  `SpendingFamily`. When supplied, these are translated to the
  underlying `(sfu, sfupar)` / `(sfl, sflpar)` arguments.

## Value

A `GSDTuneJob` R6 object.

## Details

Any argument can be replaced by a tuning specification created by
`tune_*()`. Use `SpendingSpec` / `SpendingFamily` via `upper=` and
`lower=` for dependency-aware spending function tuning.

## Examples

``` r
job <- gsDesignTune(
  k = 3,
  test.type = 4,
  alpha = tune_values(list(0.025, 0.03))
)
# \donttest{
job$run(strategy = "grid", parallel = FALSE, seed = 1)
utils::head(job$results())
#>   alpha config_id status error_message warnings
#> 1 0.025         1     ok          <NA>     <NA>
#> 2 0.030         2     ok          <NA>     <NA>
#>                          cache_key design_rds   call_args k test.type beta
#> 1 80ff9bd71804790b9770dedebc97b8e1       <NA> 3, 4, 0.025 3         4  0.1
#> 2 568a75220e8cd9d6514057e9a0b6edd4       <NA>  3, 4, 0.03 3         4  0.1
#>         timing          n_I final_n_I      upper_z      lower_z      upper_p
#> 1 0.333333.... 0.356627....  1.069883 3.0107, .... -0.2387,.... 0.0013, ....
#> 2 0.333333.... 0.356983....  1.070950 2.9549, .... -0.2851,.... 0.0016, ....
#>        lower_p power           en        upper_name        lower_name
#> 1 0.5943, ....   0.9 0.624858.... Hwang-Shih-DeCani Hwang-Shih-DeCani
#> 2 0.6122, ....   0.9 0.637266.... Hwang-Shih-DeCani Hwang-Shih-DeCani
#>   bound_summary  final_n    max_n upper_z1 lower_z1
#> 1  c("IA 1:.... 1.069883 1.069883   3.0107  -0.2387
#> 2  c("IA 1:.... 1.070950 1.070950   2.9549  -0.2851
# }
```
