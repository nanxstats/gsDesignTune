# SpendingSpec

SpendingSpec

SpendingSpec

## Value

An R6 class generator. Use `$new()` to create a `SpendingSpec` object.

## Details

An R6 class representing a single spending function (`fun`) and a tuning
specification for its parameter (`par`).

## Public fields

- `fun`:

  Spending function (callable with signature `(alpha, t, param)`).

- `fun_label`:

  Label captured from the constructor call (used for plotting).

- `par`:

  Tuning specification for the spending parameter.

## Methods

### Public methods

- [`SpendingSpec$new()`](#method-SpendingSpec-new)

- [`SpendingSpec$expand()`](#method-SpendingSpec-expand)

- [`SpendingSpec$clone()`](#method-SpendingSpec-clone)

------------------------------------------------------------------------

### Method `new()`

Create a new spending specification.

#### Usage

    SpendingSpec$new(fun, par = tune_fixed(NULL))

#### Arguments

- `fun`:

  Spending function.

- `par`:

  Spending parameter specification.

------------------------------------------------------------------------

### Method `expand()`

Expand to a list of spending settings (fun + concrete parameter values).

#### Usage

    SpendingSpec$expand()

------------------------------------------------------------------------

### Method `clone()`

The objects of this class are cloneable with this method.

#### Usage

    SpendingSpec$clone(deep = FALSE)

#### Arguments

- `deep`:

  Whether to make a deep clone.

## Examples

``` r
spec <- SpendingSpec$new(gsDesign::sfHSD, par = tune_seq(-4, -2, length_out = 2))
spec$expand()
#> [[1]]
#> $fun
#> function (alpha, t, param) 
#> {
#>     checkScalar(alpha, "numeric", c(0, Inf), c(FALSE, FALSE))
#>     checkScalar(param, "numeric", c(-40, 40))
#>     checkVector(t, "numeric", c(0, Inf), c(TRUE, FALSE))
#>     t[t > 1] <- 1
#>     x <- list(name = "Hwang-Shih-DeCani", param = param, parname = "gamma", 
#>         sf = sfHSD, spend = if (param == 0) t * alpha else alpha * 
#>             (1 - exp(-t * param))/(1 - exp(-param)), bound = NULL, 
#>         prob = NULL)
#>     class(x) <- "spendfn"
#>     x
#> }
#> <bytecode: 0x55b431fee0d8>
#> <environment: namespace:gsDesign>
#> 
#> $fun_label
#> [1] "gsDesign::sfHSD"
#> 
#> $par
#> [1] -4
#> 
#> attr(,"class")
#> [1] "gstune_spending"
#> 
#> [[2]]
#> $fun
#> function (alpha, t, param) 
#> {
#>     checkScalar(alpha, "numeric", c(0, Inf), c(FALSE, FALSE))
#>     checkScalar(param, "numeric", c(-40, 40))
#>     checkVector(t, "numeric", c(0, Inf), c(TRUE, FALSE))
#>     t[t > 1] <- 1
#>     x <- list(name = "Hwang-Shih-DeCani", param = param, parname = "gamma", 
#>         sf = sfHSD, spend = if (param == 0) t * alpha else alpha * 
#>             (1 - exp(-t * param))/(1 - exp(-param)), bound = NULL, 
#>         prob = NULL)
#>     class(x) <- "spendfn"
#>     x
#> }
#> <bytecode: 0x55b431fee0d8>
#> <environment: namespace:gsDesign>
#> 
#> $fun_label
#> [1] "gsDesign::sfHSD"
#> 
#> $par
#> [1] -2
#> 
#> attr(,"class")
#> [1] "gstune_spending"
#> 
```
