# Dependent tuning specification

`tune_dep()` defines candidates for one argument as a function of other
arguments.

## Usage

``` r
tune_dep(depends_on, map)
```

## Arguments

- depends_on:

  Character vector of argument names this specification depends on.

- map:

  A function returning either a `tune_*()` specification or a fixed
  value. The function should have arguments matching `depends_on` (or
  use `...`).

## Value

A `gstune_spec` object.

## Examples

``` r
# sfupar depends on sfu
tune_dep(
  depends_on = "sfu",
  map = function(sfu) {
    if (identical(sfu, gsDesign::sfLDOF)) tune_fixed(0) else tune_seq(-4, 4, 9)
  }
)
#> $type
#> [1] "dep"
#> 
#> $depends_on
#> [1] "sfu"
#> 
#> $map
#> function (sfu) 
#> {
#>     if (identical(sfu, gsDesign::sfLDOF)) 
#>         tune_fixed(0)
#>     else tune_seq(-4, 4, 9)
#> }
#> <environment: 0x55fef5f6eb78>
#> 
#> $call
#> tune_dep(depends_on = "sfu", map = function(sfu) {
#>     if (identical(sfu, gsDesign::sfLDOF)) 
#>         tune_fixed(0)
#>     else tune_seq(-4, 4, 9)
#> })
#> 
#> attr(,"class")
#> [1] "gstune_spec"
```
