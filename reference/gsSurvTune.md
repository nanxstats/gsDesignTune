# Create a tune job for `gsDesign::gsSurv()`

Create a tune job for
[`gsDesign::gsSurv()`](https://keaven.github.io/gsDesign/reference/nSurv.html)

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
