# gsDesignTune 0.1.0

## New features

- `gsDesignTune()`, `gsSurvTune()`, and `gsSurvCalendarTune()` create a
  `GSDTuneJob` for dependency-aware scenario exploration of
  `gsDesign::gsDesign()` / `gsDesign::gsSurv()` / `gsDesign::gsSurvCalendar()`
  designs.
- Tune specifications `tune_fixed()`, `tune_values()`, `tune_seq()`, `tune_int()`, `tune_choice()`, and `tune_dep()` for grid/random search with dependent parameters.
- Spending UX via `SpendingSpec` and `SpendingFamily` to tune spending function
  families with parameter candidates.
- Parallel evaluation with {future.apply} (user controls `future::plan()`)
  and progress reporting via {progressr}.
- Standardized metric extraction (uses `gsDesign::gsBoundSummary()`
  when available), plus ranking (`$best()`), Pareto filtering (`$pareto()`),
  plotting (`$plot()`), and reporting (`$report()`).
- Reproducibility/audit features: stored job spec + `sessionInfo()`,
  per-configuration warnings/errors, and call reconstruction via `$call_args(i)`;
  optional disk caching via `cache_dir`.
