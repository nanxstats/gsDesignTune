# Integer sequence candidates

Integer sequence candidates

## Usage

``` r
tune_int(from, to, by = 1)
```

## Arguments

- from, to:

  Integer scalars.

- by:

  Integer scalar step size.

## Value

A `gstune_spec` object.

## Examples

``` r
tune_int(2, 5)
#> $type
#> [1] "int"
#> 
#> $from
#> [1] 2
#> 
#> $to
#> [1] 5
#> 
#> $by
#> [1] 1
#> 
#> $call
#> tune_int(from = 2, to = 5)
#> 
#> attr(,"class")
#> [1] "gstune_spec"
```
