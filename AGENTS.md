# AGENTS.md

gsDesignTune prioritizes **user experience, reproducibility, and auditability** for systematic design-space exploration of group sequential designs from {gsDesign}. Keep changes small, explicit, and easy to review.

## Repo layout

- `R/`: package code (R6 classes, tune specs, execution engine, metrics).
- `inst/report/`: HTML report template used by `GSDTuneJob$report()`.
- `vignettes/`: end-to-end examples; should render without manual steps beyond `devtools::load_all()`.
- `tests/testthat/`: testthat edition 3 + snapshots.
- `vendor/`: upstream sources for reference only; never modify; excluded from builds via `.Rbuildignore`.

## Development workflow

- Load locally: `devtools::load_all(".")`
- Regenerate docs/NAMESPACE: `roxygen2::roxygenise()`
- Run tests: `devtools::test()`
- Render a vignette (important): `devtools::load_all("."); rmarkdown::render("vignettes/<name>.Rmd")`

## Design principles to preserve

- **No global parallel plan**: never call `future::plan()` inside package code; respect the user's plan. Parallelization is via `future.apply::future_lapply()` with {progressr}.
- **Never drop failures**: each configuration must be recorded with `status`, `error_message`, and `warnings`. Failed configs stay in the results table.
- **Audit trail**: keep `job$spec` complete (base args, tuned args, strategy, timestamps, `sessionInfo()`), and keep `call_args` reconstructable for any configuration.
- **Vector args are atomic**: treat vector-valued arguments (e.g., `timing`, `gamma`, `R`) as a single setting; use `tune_values(list(...))`, not element-wise expansion.
- **Dependencies are explicit**: express dependencies using `tune_dep()` (general) or `SpendingSpec`/`SpendingFamily` (preferred for spending functions). Dependency graphs must be acyclic.

## Implementation conventions

- Keep non-scalar values as list-columns; simplify only true scalar atomic columns. Prefer helpers already in the codebase (e.g., list-column simplification and labeling).
- Be careful with function-valued columns: printing/plotting must not break when a column contains functions (see `toString.function` and plot-time labeling helpers).
- In report templates (`inst/report/*.Rmd`), qualify common functions (`utils::str`, `utils::head`, etc.) because rendering uses a minimal environment.
- Don't add new dependencies casually. If a new package is needed for UX or correctness, ask first.

## When changing exports / user-facing API

- Update roxygen docs and re-run `roxygen2::roxygenise()` (regenerates `NAMESPACE` and `man/`).
- Update `_pkgdown.yml` `reference` sections to match all exports.
- Add a concise entry to `NEWS.md` and (if relevant) update `README.md` examples.
- Add/adjust tests (prefer focused unit tests + one snapshot for key metrics).
