# Create a tune job for `gsDesign::gsSurv()`

`gsSurvTune()` is a drop-in replacement for
[`gsDesign::gsSurv()`](https://keaven.github.io/gsDesign/reference/nSurv.html)
that returns a tune job object instead of immediately running a single
design.

## Usage

``` r
gsSurvTune(..., upper = NULL, lower = NULL)
```

## Arguments

- ...:

  Arguments to
  [`gsDesign::gsSurv()`](https://keaven.github.io/gsDesign/reference/nSurv.html).
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
job <- gsSurvTune(
  k = 3,
  test.type = 4,
  hr = tune_values(list(0.6, 0.7))
)
# \donttest{
job$run(strategy = "grid", parallel = FALSE, seed = 1)
utils::head(job$results())
#>    hr config_id status error_message warnings                        cache_key
#> 1 0.6         1     ok          <NA>     <NA> 3689b99dfda3ad5e3b30fc37fe60d282
#> 2 0.7         2     ok          <NA>     <NA> 19751893a549af4ae938f26c8326130c
#>   design_rds call_args k test.type alpha beta       timing          n_I
#> 1       <NA> 3, 4, 0.6 3         4 0.025  0.1 0.333333.... 57.23055....
#> 2       <NA> 3, 4, 0.7 3         4 0.025  0.1 0.333333.... 117.5472....
#>   final_n_I      upper_z      lower_z      upper_p      lower_p power
#> 1  171.6917 3.0107, .... -0.2388,.... 0.0013, .... 0.5944, ....   0.9
#> 2  352.6417 3.0107, .... -0.2388,.... 0.0013, .... 0.5944, ....   0.9
#>             en        upper_name        lower_name bound_summary final_events
#> 1 100.2770.... Hwang-Shih-DeCani Hwang-Shih-DeCani  c("IA 1:....     171.6917
#> 2 205.9613.... Hwang-Shih-DeCani Hwang-Shih-DeCani  c("IA 1:....     352.6417
#>   max_events      n_total final_n_total analysis_time upper_z1 lower_z1
#> 1   171.6917 190, 268....           268  8.465506....   3.0107  -0.2388
#> 2   352.6417 372, 530....           530  8.413321....   3.0107  -0.2388
# }
```
