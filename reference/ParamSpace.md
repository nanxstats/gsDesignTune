# ParamSpace

ParamSpace

ParamSpace

## Details

Internal R6 class to manage tuned parameters, candidate generation, and
dependencies for grid and random search.

## Public fields

- `params`:

  Named list of tuned parameter specifications.

- `order`:

  Topologically sorted parameter IDs for dependency resolution.

## Methods

### Public methods

- [`ParamSpace$new()`](#method-ParamSpace-new)

- [`ParamSpace$add_param()`](#method-ParamSpace-add_param)

- [`ParamSpace$set_dependency()`](#method-ParamSpace-set_dependency)

- [`ParamSpace$validate()`](#method-ParamSpace-validate)

- [`ParamSpace$grid()`](#method-ParamSpace-grid)

- [`ParamSpace$sample_random()`](#method-ParamSpace-sample_random)

- [`ParamSpace$clone()`](#method-ParamSpace-clone)

------------------------------------------------------------------------

### Method `new()`

Create a new parameter space.

#### Usage

    ParamSpace$new()

------------------------------------------------------------------------

### Method `add_param()`

Add a tuned parameter specification.

#### Usage

    ParamSpace$add_param(id, spec)

#### Arguments

- `id`:

  Parameter ID (argument name).

- `spec`:

  Tuning specification (`tune_*()`).

------------------------------------------------------------------------

### Method `set_dependency()`

Set a dependency mapping for a tuned parameter.

#### Usage

    ParamSpace$set_dependency(id, depends_on, map)

#### Arguments

- `id`:

  Parameter ID to modify.

- `depends_on`:

  Names that must be available in the context.

- `map`:

  Mapping function returning a `tune_*()` spec or fixed value.

------------------------------------------------------------------------

### Method `validate()`

Validate the space and compute dependency order.

#### Usage

    ParamSpace$validate(base_context = list())

#### Arguments

- `base_context`:

  Named list of fixed values available for dependencies.

------------------------------------------------------------------------

### Method [`grid()`](https://rdrr.io/r/graphics/grid.html)

Generate a dependency-aware Cartesian product (grid).

#### Usage

    ParamSpace$grid(base_context = list())

#### Arguments

- `base_context`:

  Named list of fixed values available for dependencies.

------------------------------------------------------------------------

### Method `sample_random()`

Sample configurations at random.

#### Usage

    ParamSpace$sample_random(n, base_context = list(), seed = NULL)

#### Arguments

- `n`:

  Number of configurations to sample.

- `base_context`:

  Named list of fixed values available for dependencies.

- `seed`:

  Optional seed for reproducible sampling.

------------------------------------------------------------------------

### Method `clone()`

The objects of this class are cloneable with this method.

#### Usage

    ParamSpace$clone(deep = FALSE)

#### Arguments

- `deep`:

  Whether to make a deep clone.
