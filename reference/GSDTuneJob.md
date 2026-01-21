# GSDTuneJob

GSDTuneJob

GSDTuneJob

## Details

R6 class representing a dependency-aware tuning job for group sequential
designs created by
[`gsDesign::gsDesign()`](https://keaven.github.io/gsDesign/reference/gsDesign.html)
or
[`gsDesign::gsSurv()`](https://keaven.github.io/gsDesign/reference/nSurv.html).

## Public fields

- `target`:

  Target design function name (`"gsDesign"` or `"gsSurv"`).

- `base_args`:

  Named list of fixed arguments passed to the target function.

- `tune_specs`:

  Named list of tuning specifications for explored arguments.

- `param_space`:

  Internal parameter space used for configuration generation.

- `spec`:

  Audit record including base/tuned args and
  [`sessionInfo()`](https://rdrr.io/r/utils/sessionInfo.html).

## Methods

### Public methods

- [`GSDTuneJob$new()`](#method-GSDTuneJob-new)

- [`GSDTuneJob$run()`](#method-GSDTuneJob-run)

- [`GSDTuneJob$results()`](#method-GSDTuneJob-results)

- [`GSDTuneJob$summarize()`](#method-GSDTuneJob-summarize)

- [`GSDTuneJob$design()`](#method-GSDTuneJob-design)

- [`GSDTuneJob$call_args()`](#method-GSDTuneJob-call_args)

- [`GSDTuneJob$best()`](#method-GSDTuneJob-best)

- [`GSDTuneJob$pareto()`](#method-GSDTuneJob-pareto)

- [`GSDTuneJob$plot()`](#method-GSDTuneJob-plot)

- [`GSDTuneJob$report()`](#method-GSDTuneJob-report)

- [`GSDTuneJob$clone()`](#method-GSDTuneJob-clone)

------------------------------------------------------------------------

### Method `new()`

Create a new tune job.

#### Usage

    GSDTuneJob$new(target = c("gsDesign", "gsSurv", "gsSurvCalendar"), args)

#### Arguments

- `target`:

  Target function name (`"gsDesign"`, `"gsSurv"`, or
  `"gsSurvCalendar"`).

- `args`:

  Named list of evaluated arguments.

------------------------------------------------------------------------

### Method [`run()`](https://future.futureverse.org/reference/run.html)

Evaluate configurations under a search strategy.

#### Usage

    GSDTuneJob$run(
      strategy = c("grid", "random"),
      n = NULL,
      parallel = TRUE,
      seed = NULL,
      cache_dir = NULL,
      metrics_fun = NULL
    )

#### Arguments

- `strategy`:

  Search strategy (`"grid"` or `"random"`).

- `n`:

  Number of configurations for random search.

- `parallel`:

  Whether to evaluate configurations in parallel.

- `seed`:

  Optional seed for reproducibility.

- `cache_dir`:

  Optional directory to cache design objects as `RDS`.

- `metrics_fun`:

  Optional metric hook.

------------------------------------------------------------------------

### Method `results()`

Return the results data.frame.

#### Usage

    GSDTuneJob$results()

------------------------------------------------------------------------

### Method `summarize()`

Summarize the run (counts + numeric metric summaries).

#### Usage

    GSDTuneJob$summarize()

------------------------------------------------------------------------

### Method `design()`

Retrieve a design object for configuration `i`.

#### Usage

    GSDTuneJob$design(i)

#### Arguments

- `i`:

  Row index of the configuration.

------------------------------------------------------------------------

### Method `call_args()`

Return the underlying argument list for configuration `i`.

#### Usage

    GSDTuneJob$call_args(i)

#### Arguments

- `i`:

  Row index of the configuration.

------------------------------------------------------------------------

### Method `best()`

Rank configurations by a metric (with optional constraints).

#### Usage

    GSDTuneJob$best(metric, direction = c("min", "max"), constraints = NULL)

#### Arguments

- `metric`:

  Metric column name.

- `direction`:

  Ranking direction (`"min"` or `"max"`).

- `constraints`:

  Optional constraints (function or expression).

------------------------------------------------------------------------

### Method `pareto()`

Compute a Pareto (non-dominated) set for multiple metrics.

#### Usage

    GSDTuneJob$pareto(metrics, directions)

#### Arguments

- `metrics`:

  Metric column names.

- `directions`:

  Directions for each metric (`"min"`/`"max"`).

------------------------------------------------------------------------

### Method [`plot()`](https://rdrr.io/r/graphics/plot.default.html)

Create a quick exploration plot with ggplot2.

#### Usage

    GSDTuneJob$plot(metric, x, color = NULL, facet = NULL)

#### Arguments

- `metric`:

  Y-axis metric column name.

- `x`:

  X-axis column name.

- `color`:

  Optional color column name.

- `facet`:

  Optional faceting column name.

------------------------------------------------------------------------

### Method `report()`

Render an HTML report via rmarkdown.

#### Usage

    GSDTuneJob$report(path)

#### Arguments

- `path`:

  Output HTML file path.

------------------------------------------------------------------------

### Method `clone()`

The objects of this class are cloneable with this method.

#### Usage

    GSDTuneJob$clone(deep = FALSE)

#### Arguments

- `deep`:

  Whether to make a deep clone.
