# SpendingSpec

SpendingSpec

SpendingSpec

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
