# SpendingFamily

SpendingFamily

SpendingFamily

## Value

An R6 class generator. Use `$new()` to create a `SpendingFamily` object.

## Details

An R6 class representing a set of spending function specifications. Each
family member is a `SpendingSpec`.

## Public fields

- `members`:

  List of `SpendingSpec` objects.

## Methods

### Public methods

- [`SpendingFamily$new()`](#method-SpendingFamily-new)

- [`SpendingFamily$expand()`](#method-SpendingFamily-expand)

- [`SpendingFamily$clone()`](#method-SpendingFamily-clone)

------------------------------------------------------------------------

### Method `new()`

Create a new spending family from one or more `SpendingSpec`.

#### Usage

    SpendingFamily$new(...)

#### Arguments

- `...`:

  `SpendingSpec` objects.

------------------------------------------------------------------------

### Method `expand()`

Expand all members to spending settings.

#### Usage

    SpendingFamily$expand()

------------------------------------------------------------------------

### Method `clone()`

The objects of this class are cloneable with this method.

#### Usage

    SpendingFamily$clone(deep = FALSE)

#### Arguments

- `deep`:

  Whether to make a deep clone.

## Examples

``` r
fam <- SpendingFamily$new(
  SpendingSpec$new(gsDesign::sfHSD, par = tune_fixed(-4)),
  SpendingSpec$new(gsDesign::sfLDOF, par = tune_fixed(0))
)
fam$expand()
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
#> function (alpha, t, param = NULL) 
#> {
#>     checkScalar(alpha, "numeric", c(0, Inf), c(FALSE, FALSE))
#>     checkVector(t, "numeric", c(0, Inf), c(TRUE, FALSE))
#>     if (is.null(param) || param < 0.005 || param > 20) 
#>         param <- 1
#>     checkScalar(param, "numeric", c(0.005, 20), c(TRUE, TRUE))
#>     t[t > 1] <- 1
#>     if (param == 1) {
#>         rho <- 1
#>         txt <- "Lan-DeMets O'Brien-Fleming approximation"
#>         parname <- "none"
#>     }
#>     else {
#>         rho <- param
#>         txt <- "Generalized Lan-DeMets O'Brien-Fleming"
#>         parname <- "rho"
#>     }
#>     z <- -qnorm(alpha/2)
#>     x <- list(name = txt, param = param, parname = parname, sf = sfLDOF, 
#>         spend = 2 * (1 - pnorm(z/t^(rho/2))), bound = NULL, prob = NULL)
#>     class(x) <- "spendfn"
#>     x
#> }
#> <bytecode: 0x55b431ffe3b0>
#> <environment: namespace:gsDesign>
#> 
#> $fun_label
#> [1] "gsDesign::sfLDOF"
#> 
#> $par
#> [1] 0
#> 
#> attr(,"class")
#> [1] "gstune_spending"
#> 
```
