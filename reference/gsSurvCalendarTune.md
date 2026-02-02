# Create a tune job for `gsDesign::gsSurvCalendar()`

`gsSurvCalendarTune()` is a drop-in replacement for
[`gsDesign::gsSurvCalendar()`](https://keaven.github.io/gsDesign/reference/gsSurvCalendar.html)
that returns a tune job object instead of immediately running a single
design.

## Usage

``` r
gsSurvCalendarTune(..., upper = NULL, lower = NULL)
```

## Arguments

- ...:

  Arguments to
  [`gsDesign::gsSurvCalendar()`](https://keaven.github.io/gsDesign/reference/gsSurvCalendar.html).
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
job <- gsSurvCalendarTune(
  calendarTime = tune_values(list(c(12, 24, 36), c(12, 24, 48))),
  spending = c("information", "calendar")
)
# \donttest{
job$run(strategy = "grid", parallel = FALSE, seed = 1)
utils::head(job$results())
#>   calendarTime config_id status error_message warnings
#> 1   12, 24, 36         1     ok          <NA>     <NA>
#> 2   12, 24, 48         2     ok          <NA>     <NA>
#>                          cache_key design_rds    call_args k test.type alpha
#> 1 98468c90a3faa29f0afcf6656e8f4d3c       <NA> c("infor.... 3         4 0.025
#> 2 d5a31e561e166e47783110174c34c3ae       <NA> c("infor.... 3         4 0.025
#>   beta       timing          n_I final_n_I      upper_z      lower_z
#> 1  0.1 0.291608.... 50.41988....  172.9027 3.0811, .... -0.4228,....
#> 2  0.1 0.169188.... 28.37513....  167.7133 3.3193, .... -1.1287,....
#>        upper_p      lower_p power           en        upper_name
#> 1 0.001, 0.... 0.6638, ....   0.9 110.2262.... Hwang-Shih-DeCani
#> 2 5e-04, 0.... 0.8705, ....   0.9 105.9637.... Hwang-Shih-DeCani
#>          lower_name bound_summary final_events max_events      n_total
#> 1 Hwang-Shih-DeCani  c("IA 1:....     172.9027   172.9027 130, 194....
#> 2 Hwang-Shih-DeCani  c("IA 1:....     167.7133   167.7133 74, 146, 182
#>   final_n_total analysis_time upper_z1 lower_z1
#> 1           194    12, 24, 36   3.0811  -0.4228
#> 2           182    12, 24, 48   3.3193  -1.1287
# }
```
