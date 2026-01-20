# Changelog

## gsDesignTune 0.1.0

### New features

- [`gsDesignTune()`](https://nanx.me/gsDesignTune/reference/gsDesignTune.md),
  [`gsSurvTune()`](https://nanx.me/gsDesignTune/reference/gsSurvTune.md),
  and
  [`gsSurvCalendarTune()`](https://nanx.me/gsDesignTune/reference/gsSurvCalendarTune.md)
  create a `GSDTuneJob` for dependency-aware scenario exploration of
  [`gsDesign::gsDesign()`](https://keaven.github.io/gsDesign/reference/gsDesign.html)
  /
  [`gsDesign::gsSurv()`](https://keaven.github.io/gsDesign/reference/nSurv.html)
  /
  [`gsDesign::gsSurvCalendar()`](https://keaven.github.io/gsDesign/reference/gsSurvCalendar.html)
  designs.
- Tune specifications
  [`tune_fixed()`](https://nanx.me/gsDesignTune/reference/tune_fixed.md),
  [`tune_values()`](https://nanx.me/gsDesignTune/reference/tune_values.md),
  [`tune_seq()`](https://nanx.me/gsDesignTune/reference/tune_seq.md),
  [`tune_int()`](https://nanx.me/gsDesignTune/reference/tune_int.md),
  [`tune_choice()`](https://nanx.me/gsDesignTune/reference/tune_choice.md),
  and [`tune_dep()`](https://nanx.me/gsDesignTune/reference/tune_dep.md)
  for grid/random search with dependent parameters.
- Spending UX via `SpendingSpec` and `SpendingFamily` to tune spending
  function families with parameter candidates.
- Parallel evaluation with {future.apply} (user controls
  [`future::plan()`](https://future.futureverse.org/reference/plan.html))
  and progress reporting via {progressr}.
- Standardized metric extraction (uses
  [`gsDesign::gsBoundSummary()`](https://keaven.github.io/gsDesign/reference/gsBoundSummary.html)
  when available), plus ranking (`$best()`), Pareto filtering
  (`$pareto()`), plotting (`$plot()`), and reporting (`$report()`).
- Reproducibility/audit features: stored job spec +
  [`sessionInfo()`](https://rdrr.io/r/utils/sessionInfo.html),
  per-configuration warnings/errors, and call reconstruction via
  `$call_args(i)`; optional disk caching via `cache_dir`.
