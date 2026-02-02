# Convert a function to a short label string

[`gsDesignTune()`](https://nanx.me/gsDesignTune/reference/gsDesignTune.md)
uses function-valued columns (for example, spending functions) in
results tables. This method provides a stable, readable label for such
functions to keep printing and plotting robust.

## Usage

``` r
# S3 method for class '`function`'
toString(x, ...)
```

## Arguments

- x:

  A function.

- ...:

  Unused (included for S3 method compatibility).

## Value

A character scalar.

## Examples

``` r
toString(stats::rnorm)
#> [1] "stats::rnorm"
```
