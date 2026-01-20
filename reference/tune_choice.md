# Categorical choices

`tune_choice()` defines a finite set of categorical choices. Each
argument in `...` is treated as one choice (including functions and
other objects).

## Usage

``` r
tune_choice(...)
```

## Arguments

- ...:

  Candidate values.

## Value

A `gstune_spec` object.

## Examples

``` r
tune_choice("A", "B")
#> $type
#> [1] "values"
#> 
#> $values
#> $values[[1]]
#> [1] "A"
#> 
#> $values[[2]]
#> [1] "B"
#> 
#> 
#> $call
#> tune_values(values = values)
#> 
#> attr(,"class")
#> [1] "gstune_spec"
```
