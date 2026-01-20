# Numeric sequence candidates

Numeric sequence candidates

## Usage

``` r
tune_seq(from, to, length_out)
```

## Arguments

- from, to:

  Numeric scalars.

- length_out:

  Integer scalar, the number of candidates.

## Value

A `gstune_spec` object.

## Examples

``` r
tune_seq(0.55, 0.75, length_out = 5)
#> $type
#> [1] "seq"
#> 
#> $from
#> [1] 0.55
#> 
#> $to
#> [1] 0.75
#> 
#> $length_out
#> [1] 5
#> 
#> $call
#> tune_seq(from = 0.55, to = 0.75, length_out = 5)
#> 
#> attr(,"class")
#> [1] "gstune_spec"
```
