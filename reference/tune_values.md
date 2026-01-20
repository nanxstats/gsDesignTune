# Explicit candidate values

`tune_values()` defines a finite set of candidate values. Values are
provided as a list so vector-valued candidates (e.g., `timing`) are
treated as atomic.

## Usage

``` r
tune_values(values)
```

## Arguments

- values:

  A list of candidate values.

## Value

A `gstune_spec` object.

## Examples

``` r
tune_values(list(0.55, 0.65, 0.75))
#> $type
#> [1] "values"
#> 
#> $values
#> $values[[1]]
#> [1] 0.55
#> 
#> $values[[2]]
#> [1] 0.65
#> 
#> $values[[3]]
#> [1] 0.75
#> 
#> 
#> $call
#> tune_values(values = list(0.55, 0.65, 0.75))
#> 
#> attr(,"class")
#> [1] "gstune_spec"
tune_values(list(c(0.33, 0.67, 1), c(0.5, 0.75, 1)))
#> $type
#> [1] "values"
#> 
#> $values
#> $values[[1]]
#> [1] 0.33 0.67 1.00
#> 
#> $values[[2]]
#> [1] 0.50 0.75 1.00
#> 
#> 
#> $call
#> tune_values(values = list(c(0.33, 0.67, 1), c(0.5, 0.75, 1)))
#> 
#> attr(,"class")
#> [1] "gstune_spec"
```
