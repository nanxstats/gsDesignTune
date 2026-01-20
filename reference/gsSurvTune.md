# Create a tune job for `gsDesign::gsSurv()`

[`gsDesignTune()`](https://nanx.me/gsDesignTune/reference/gsDesignTune.md)
and `gsSurvTune()` are drop-in replacements for
[`gsDesign::gsDesign()`](https://keaven.github.io/gsDesign/reference/gsDesign.html)
and
[`gsDesign::gsSurv()`](https://keaven.github.io/gsDesign/reference/nSurv.html)
that return a tune job object instead of immediately running a single
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
