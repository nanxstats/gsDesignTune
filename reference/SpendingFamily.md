# SpendingFamily

SpendingFamily

SpendingFamily

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
