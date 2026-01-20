# Fixed (non-tuned) value

Use `tune_fixed()` to explicitly mark a value as fixed. This is mainly
useful inside dependent specifications such as
[`tune_dep()`](https://nanx.me/gsDesignTune/reference/tune_dep.md).

## Usage

``` r
tune_fixed(x)
```

## Arguments

- x:

  Any R object.

## Value

A `gstune_spec` object.

## Examples

``` r
tune_fixed(0.025)
#> $type
#> [1] "fixed"
#> 
#> $value
#> [1] 0.025
#> 
#> $call
#> tune_fixed(x = 0.025)
#> 
#> attr(,"class")
#> [1] "gstune_spec"
```
