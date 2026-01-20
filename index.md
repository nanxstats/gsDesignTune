# gsDesignTune

gsDesignTune enables systematic, dependency-aware scenario exploration
for group sequential designs created by
[`gsDesign::gsDesign()`](https://keaven.github.io/gsDesign/reference/gsDesign.html)
and
[`gsDesign::gsSurv()`](https://keaven.github.io/gsDesign/reference/nSurv.html).

It is designed for **design-space evaluation** (ranking, filtering,
Pareto trade-offs) rather than claiming a single “optimal design”.

## Installation

You can install the development version of gsDesignTune from GitHub
with:

``` r
# install.packages("pak")
pak::pak("nanxstats/gsDesignTune")
```

## Features

- Drop-in workflow: replace
  [`gsDesign()`](https://keaven.github.io/gsDesign/reference/gsDesign.html)/[`gsSurv()`](https://keaven.github.io/gsDesign/reference/nSurv.html)
  with
  [`gsDesignTune()`](https://nanx.me/gsDesignTune/reference/gsDesignTune.md)/[`gsSurvTune()`](https://nanx.me/gsDesignTune/reference/gsSurvTune.md),
  then `$run()`.
- Dependency-aware tuning: express relationships like spending function
  ↔︎ spending parameter.
- Grid and random search over candidate sets (vector-valued args are
  treated atomically).
- Parallel evaluation via {future} / {future.apply} with progress via
  {progressr} (no global plan set).
- Reproducible and auditable results: per-config warnings/errors +
  reconstructable underlying call.
- Optional caching of design objects to disk and HTML reporting via
  {rmarkdown}.

## Quick start

Evaluate time-to-event designs:

``` r
library(gsDesign)
library(gsDesignTune)
library(future)

plan(multisession, workers = 8)

job <- gsSurvTune(
  k = 3,
  test.type = 4,
  alpha = 0.025,
  beta = 0.10,
  timing = tune_values(list(c(0.33, 0.67, 1), c(0.5, 0.75, 1))),
  hr = tune_seq(0.55, 0.75, length_out = 5),
  upper = SpendingFamily$new(
    SpendingSpec$new(sfLDOF, par = tune_fixed(0)),
    SpendingSpec$new(sfHSD, par = tune_seq(-4, 4, length_out = 9))
  ),
  lower = SpendingSpec$new(sfLDOF, par = tune_fixed(0)),
  lambdaC = log(2) / 6,
  eta = 0.01,
  gamma = c(2.5, 5, 7.5, 10),
  R = c(2, 2, 2, 6),
  T = 18,
  minfup = 6,
  ratio = 1
)

job$run(strategy = "grid", parallel = TRUE, seed = 1, cache_dir = "gstune_cache")

res <- job$results()
head(res)

job$best("final_events", direction = "min")
job$pareto(metrics = c("final_events", "upper_z1"), directions = c("min", "min"))

job$plot(metric = "final_events", x = "hr", color = "upper_fun")
```

![](reference/figures/README-example-1.svg)

``` r
job$report("gstune_report.html")
```

## Tune specifications

- `tune_fixed(x)`: explicit fixed value (useful inside dependencies)
- `tune_values(list(...))`: explicit candidates (supports vector-valued
  candidates)
- `tune_seq(from, to, length_out)`, `tune_int(from, to, by)`
- `tune_choice(...)`: categorical choices
- `tune_dep(depends_on, map)`: dependent mapping for any argument

See vignettes for end-to-end examples, spending function tuning, and
parallel + reproducible reporting.
