#' Create a tune job for `gsDesign::gsDesign()`
#'
#' `gsDesignTune()` and `gsSurvTune()` are drop-in replacements for
#' [gsDesign::gsDesign()] and [gsDesign::gsSurv()] that return a tune job object
#' instead of immediately running a single design.
#'
#' Any argument can be replaced by a tuning specification created by `tune_*()`.
#' Use `SpendingSpec` / `SpendingFamily` via `upper=` and `lower=` for
#' dependency-aware spending function tuning.
#'
#' @param ... Arguments to [gsDesign::gsDesign()]. Any argument can be replaced
#'   by a `tune_*()` specification.
#' @param upper,lower Optional spending specifications provided as
#'   `SpendingSpec` or `SpendingFamily`. When supplied, these are translated to
#'   the underlying `(sfu, sfupar)` / `(sfl, sflpar)` arguments.
#'
#' @return A `GSDTuneJob` R6 object.
#' @export
gsDesignTune <- function(..., upper = NULL, lower = NULL) {
  args <- list(...)
  args$upper <- upper
  args$lower <- lower
  GSDTuneJob$new(target = "gsDesign", args = args)
}

#' Create a tune job for `gsDesign::gsSurv()`
#'
#' `gsDesignTune()` and `gsSurvTune()` are drop-in replacements for
#' [gsDesign::gsDesign()] and [gsDesign::gsSurv()] that return a tune job object
#' instead of immediately running a single design.
#'
#' Any argument can be replaced by a tuning specification created by `tune_*()`.
#' Use `SpendingSpec` / `SpendingFamily` via `upper=` and `lower=` for
#' dependency-aware spending function tuning.
#'
#' @param ... Arguments to [gsDesign::gsSurv()]. Any argument can be replaced
#'   by a `tune_*()` specification.
#' @param upper,lower Optional spending specifications provided as
#'   `SpendingSpec` or `SpendingFamily`. When supplied, these are translated to
#'   the underlying `(sfu, sfupar)` / `(sfl, sflpar)` arguments.
#'
#' @return A `GSDTuneJob` R6 object.
#' @export
gsSurvTune <- function(..., upper = NULL, lower = NULL) {
  args <- list(...)
  args$upper <- upper
  args$lower <- lower
  GSDTuneJob$new(target = "gsSurv", args = args)
}

#' GSDTuneJob
#'
#' R6 class representing a dependency-aware tuning job for group sequential
#' designs created by [gsDesign::gsDesign()] or [gsDesign::gsSurv()].
#'
#' @field target Target design function name (`"gsDesign"` or `"gsSurv"`).
#' @field base_args Named list of fixed arguments passed to the target function.
#' @field tune_specs Named list of tuning specifications for explored arguments.
#' @field param_space Internal parameter space used for configuration generation.
#' @field spec Audit record including base/tuned args and `sessionInfo()`.
#'
#' @param target Target function name.
#' @param args Named list of arguments (evaluated).
#' @param strategy Search strategy (`"grid"` or `"random"`).
#' @param n Number of configurations for random search.
#' @param parallel Whether to evaluate configurations in parallel via `{future}`.
#' @param seed Optional seed for reproducibility.
#' @param cache_dir Optional directory for caching `RDS` design objects.
#' @param metrics_fun Optional user hook: `function(design_obj, base_args, tuned_args)`.
#' @param i Row index of the configuration.
#' @param metric Metric column name for ranking/plotting.
#' @param direction Ranking direction (`"min"` or `"max"`).
#' @param constraints Optional constraints for ranking (function or expression).
#' @param metrics Metric column names for Pareto filtering.
#' @param directions Directions for Pareto metrics (`"min"`/`"max"`).
#' @param x X-axis column name for plotting.
#' @param color Optional color grouping column name for plotting.
#' @param facet Optional faceting column name for plotting.
#' @param path Output path for HTML report.
#'
#' @export
GSDTuneJob <- R6::R6Class(
  "GSDTuneJob",
  public = list(
    target = NULL,
    base_args = NULL,
    tune_specs = NULL,
    param_space = NULL,
    spec = NULL,
    #' @description
    #' Create a new tune job.
    #'
    #' @param target Target function name (`"gsDesign"` or `"gsSurv"`).
    #' @param args Named list of evaluated arguments.
    initialize = function(target = c("gsDesign", "gsSurv"), args) {
      target <- match.arg(target)
      if (!is.list(args)) {
        stop("`args` must be a list.", call. = FALSE)
      }

      parsed <- gstune_parse_args(args)

      self$target <- target
      self$base_args <- parsed$base_args
      self$tune_specs <- parsed$tune_specs
      self$param_space <- parsed$param_space
      self$spec <- list(
        target = target,
        base_args = self$base_args,
        tune_specs = lapply(self$tune_specs, gstune_spec_to_list),
        created_at = format(Sys.time(), "%Y-%m-%d %H:%M:%S %z"),
        session_info = utils::sessionInfo()
      )
      private$results_df <- NULL
      private$configs_df <- NULL
      private$designs <- new.env(parent = emptyenv())
      private$cache_dir <- NULL
      invisible(self)
    },
    #' @description
    #' Evaluate configurations under a search strategy.
    #'
    #' @param strategy Search strategy (`"grid"` or `"random"`).
    #' @param n Number of configurations for random search.
    #' @param parallel Whether to evaluate configurations in parallel.
    #' @param seed Optional seed for reproducibility.
    #' @param cache_dir Optional directory to cache design objects as `RDS`.
    #' @param metrics_fun Optional metric hook.
    run = function(strategy = c("grid", "random"), n = NULL, parallel = TRUE, seed = NULL, cache_dir = NULL, metrics_fun = NULL) {
      strategy <- match.arg(strategy)
      if (!is.null(metrics_fun) && !is.function(metrics_fun)) {
        stop("`metrics_fun` must be a function.", call. = FALSE)
      }
      if (!is.null(seed)) {
        if (!is.numeric(seed) || length(seed) != 1L) {
          stop("`seed` must be a numeric scalar.", call. = FALSE)
        }
        set.seed(as.integer(seed))
      }
      if (!is.null(cache_dir)) {
        if (!is.character(cache_dir) || length(cache_dir) != 1L || !nzchar(cache_dir)) {
          stop("`cache_dir` must be a non-empty character scalar.", call. = FALSE)
        }
        dir.create(cache_dir, recursive = TRUE, showWarnings = FALSE)
        private$cache_dir <- cache_dir
        saveRDS(self$spec, file = file.path(cache_dir, "spec.rds"))
      } else {
        private$cache_dir <- NULL
      }

      base_context <- self$base_args
      if (strategy == "grid") {
        configs <- self$param_space$grid(base_context = base_context)
      } else {
        if (is.null(n)) {
          stop("For `strategy = \"random\"`, `n` must be provided.", call. = FALSE)
        }
        configs <- self$param_space$sample_random(n = n, base_context = base_context, seed = seed)
      }

      configs <- gstune_add_derived_config_cols(configs)
      configs$config_id <- seq_len(nrow(configs))
      private$configs_df <- configs

      fn <- getExportedValue("gsDesign", self$target)
      tune_ids <- names(self$tune_specs)
      n_configs <- nrow(configs)

      eval_one <- function(i, p = NULL) {
        if (!is.null(p)) {
          p()
        }
        tuned_args <- stats::setNames(vector("list", length(tune_ids)), tune_ids)
        for (id in tune_ids) {
          tuned_args[[id]] <- configs[[id]][[i]]
        }
        full_args <- gstune_build_call_args(self$base_args, tuned_args)

        out <- gstune_eval_design(
          fn = fn,
          args = full_args,
          config_id = configs$config_id[[i]],
          target = self$target,
          base_args = self$base_args,
          tuned_args = tuned_args,
          metrics_fun = metrics_fun
        )

        has_design <- !is.null(out$design)
        if (!is.null(private$cache_dir) && identical(out$status, "ok") && has_design) {
          design_path <- file.path(private$cache_dir, paste0("design_", out$cache_key, ".rds"))
          if (!file.exists(design_path)) saveRDS(out$design, file = design_path)
          out$design_rds <- design_path
        }
        if (has_design) {
          assign(as.character(out$config_id), out$design, envir = private$designs)
        }
        out$design <- NULL
        out
      }

      results <- progressr::with_progress({
        p <- progressr::progressor(along = seq_len(n_configs))
        if (isTRUE(parallel)) {
          future.apply::future_lapply(
            seq_len(n_configs),
            function(i) eval_one(i, p = p),
            future.seed = !is.null(seed)
          )
        } else {
          lapply(seq_len(n_configs), eval_one, p = p)
        }
      })

      private$results_df <- gstune_results_to_df(results, configs = configs)
      if (!is.null(private$cache_dir)) {
        saveRDS(private$results_df, file = file.path(private$cache_dir, "metrics.rds"))
      }

      self$spec$last_run <- list(
        strategy = strategy,
        n = n,
        parallel = isTRUE(parallel),
        seed = seed,
        cache_dir = cache_dir,
        ran_at = format(Sys.time(), "%Y-%m-%d %H:%M:%S %z")
      )

      invisible(self)
    },
    #' @description
    #' Return the results data.frame.
    results = function() {
      if (is.null(private$results_df)) {
        stop("No results yet. Run `$run()` first.", call. = FALSE)
      }
      private$results_df
    },
    #' @description
    #' Summarize the run (counts + numeric metric summaries).
    summarize = function() {
      df <- self$results()
      status_tab <- table(df$status)
      ok <- df[df$status == "ok", , drop = FALSE]
      num_cols <- names(ok)[vapply(ok, is.numeric, logical(1))]
      metrics_summary <- if (length(num_cols) == 0L) {
        NULL
      } else {
        summary(ok[, num_cols, drop = FALSE])
      }
      list(
        n_configs = nrow(df),
        status = status_tab,
        n_warnings = sum(!is.na(df$warnings) & nzchar(df$warnings)),
        metrics = metrics_summary
      )
    },
    #' @description
    #' Retrieve a design object for configuration `i`.
    #'
    #' @param i Row index of the configuration.
    design = function(i) {
      if (is.null(private$results_df)) {
        stop("No results yet. Run `$run()` first.", call. = FALSE)
      }
      if (!is.numeric(i) || length(i) != 1L) {
        stop("`i` must be a numeric scalar (row index).", call. = FALSE)
      }
      i <- as.integer(i)
      if (i < 1L || i > nrow(private$results_df)) {
        stop("`i` is out of range.", call. = FALSE)
      }
      config_id <- private$results_df$config_id[[i]]
      key <- as.character(config_id)
      if (exists(key, envir = private$designs, inherits = FALSE)) {
        return(get(key, envir = private$designs, inherits = FALSE))
      }
      design_rds <- private$results_df$design_rds[[i]]
      if (!is.null(design_rds) && is.character(design_rds) && file.exists(design_rds)) {
        obj <- readRDS(design_rds)
        assign(key, obj, envir = private$designs)
        return(obj)
      }
      stop("Design object is not available (not cached).", call. = FALSE)
    },
    #' @description
    #' Return the underlying argument list for configuration `i`.
    #'
    #' @param i Row index of the configuration.
    call_args = function(i) {
      df <- self$results()
      if (!is.numeric(i) || length(i) != 1L) {
        stop("`i` must be a numeric scalar (row index).", call. = FALSE)
      }
      i <- as.integer(i)
      if (i < 1L || i > nrow(df)) {
        stop("`i` is out of range.", call. = FALSE)
      }
      df$call_args[[i]]
    },
    #' @description
    #' Rank configurations by a metric (with optional constraints).
    #'
    #' @param metric Metric column name.
    #' @param direction Ranking direction (`"min"` or `"max"`).
    #' @param constraints Optional constraints (function or expression).
    best = function(metric, direction = c("min", "max"), constraints = NULL) {
      direction <- match.arg(direction)
      df <- self$results()
      df <- df[df$status == "ok", , drop = FALSE]
      if (!metric %in% names(df)) {
        stop(sprintf("Unknown metric: '%s'.", metric), call. = FALSE)
      }
      df <- gstune_apply_constraints(df, constraints)
      ord <- df[[metric]]
      if (!is.numeric(ord)) {
        stop("`metric` must be numeric for ranking.", call. = FALSE)
      }
      o <- order(ord, decreasing = identical(direction, "max"), na.last = TRUE)
      df[o, , drop = FALSE]
    },
    #' @description
    #' Compute a Pareto (non-dominated) set for multiple metrics.
    #'
    #' @param metrics Metric column names.
    #' @param directions Directions for each metric (`"min"`/`"max"`).
    pareto = function(metrics, directions) {
      df <- self$results()
      df <- df[df$status == "ok", , drop = FALSE]
      if (!is.character(metrics) || length(metrics) < 1L) {
        stop("`metrics` must be a non-empty character vector.", call. = FALSE)
      }
      if (!is.character(directions) || length(directions) != length(metrics)) {
        stop("`directions` must be a character vector matching `metrics` length.", call. = FALSE)
      }
      if (!all(directions %in% c("min", "max"))) {
        stop("`directions` must be 'min' or 'max'.", call. = FALSE)
      }
      missing_metrics <- setdiff(metrics, names(df))
      if (length(missing_metrics) > 0L) {
        stop(sprintf("Unknown metrics: %s", paste(missing_metrics, collapse = ", ")), call. = FALSE)
      }
      for (m in metrics) {
        if (!is.numeric(df[[m]])) {
          stop(sprintf("Metric '%s' must be numeric for Pareto ranking.", m), call. = FALSE)
        }
      }
      df <- df[stats::complete.cases(df[, metrics, drop = FALSE]), , drop = FALSE]
      if (nrow(df) == 0L) {
        return(df)
      }
      mat <- as.matrix(df[, metrics, drop = FALSE])
      for (j in seq_along(metrics)) {
        if (directions[[j]] == "max") {
          mat[, j] <- -mat[, j]
        }
      }
      n <- nrow(mat)
      dominated <- logical(n)
      for (i in seq_len(n)) {
        if (dominated[[i]]) next
        for (j in seq_len(n)) {
          if (i == j) next
          if (all(mat[j, ] <= mat[i, ]) && any(mat[j, ] < mat[i, ])) {
            dominated[[i]] <- TRUE
            break
          }
        }
      }
      df[!dominated, , drop = FALSE]
    },
    #' @description
    #' Create a quick exploration plot with `{ggplot2}`.
    #'
    #' @param metric Y-axis metric column name.
    #' @param x X-axis column name.
    #' @param color Optional color column name.
    #' @param facet Optional faceting column name.
    plot = function(metric, x, color = NULL, facet = NULL) {
      if (!requireNamespace("ggplot2", quietly = TRUE)) {
        stop("Package 'ggplot2' is required for `$plot()`.", call. = FALSE)
      }
      df <- self$results()
      df <- df[df$status == "ok", , drop = FALSE]
      if (!metric %in% names(df)) stop(sprintf("Unknown `metric`: '%s'.", metric), call. = FALSE)
      if (!x %in% names(df)) stop(sprintf("Unknown `x`: '%s'.", x), call. = FALSE)
      if (!is.null(color) && !color %in% names(df)) stop(sprintf("Unknown `color`: '%s'.", color), call. = FALSE)
      if (!is.null(facet) && !facet %in% names(df)) stop(sprintf("Unknown `facet`: '%s'.", facet), call. = FALSE)
      if (is.list(df[[x]])) stop("`x` must be an atomic column (not a list-column).", call. = FALSE)
      if (is.list(df[[metric]])) stop("`metric` must be an atomic column (not a list-column).", call. = FALSE)

      df_plot <- df
      color_col <- color
      facet_col <- facet
      if (!is.null(color_col) && is.list(df_plot[[color_col]])) {
        tmp <- paste0(color_col, "_label")
        df_plot[[tmp]] <- gstune_label_list_col(df_plot[[color_col]])
        color_col <- tmp
      }
      if (!is.null(facet_col) && is.list(df_plot[[facet_col]])) {
        tmp <- paste0(facet_col, "_label")
        df_plot[[tmp]] <- gstune_label_list_col(df_plot[[facet_col]])
        facet_col <- tmp
      }

      mapping <- if (is.null(color_col)) {
        ggplot2::aes_string(x = x, y = metric)
      } else {
        ggplot2::aes_string(x = x, y = metric, color = color_col)
      }
      p <- ggplot2::ggplot(df_plot, mapping) +
        ggplot2::geom_point() +
        ggplot2::theme_minimal()
      if (!is.null(facet_col)) {
        p <- p + ggplot2::facet_wrap(stats::as.formula(paste("~", facet_col)))
      }
      p
    },
    #' @description
    #' Render an HTML report via `{rmarkdown}`.
    #'
    #' @param path Output HTML file path.
    report = function(path) {
      if (!requireNamespace("rmarkdown", quietly = TRUE)) {
        stop("Package 'rmarkdown' is required for `$report()`.", call. = FALSE)
      }
      if (!requireNamespace("knitr", quietly = TRUE)) {
        stop("Package 'knitr' is required for `$report()`.", call. = FALSE)
      }
      if (is.null(private$results_df)) {
        stop("No results yet. Run `$run()` first.", call. = FALSE)
      }
      if (!is.character(path) || length(path) != 1L || !nzchar(path)) {
        stop("`path` must be a non-empty character scalar.", call. = FALSE)
      }
      template <- system.file("report", "gstune_report.Rmd", package = "gsDesignTune")
      if (template == "") {
        stop("Internal report template not found.", call. = FALSE)
      }
      tmp <- tempfile(fileext = ".Rmd")
      ok <- file.copy(template, tmp, overwrite = TRUE)
      if (!isTRUE(ok)) stop("Failed to prepare report template.", call. = FALSE)
      rmarkdown::render(
        input = tmp,
        output_file = path,
        params = list(job = self),
        envir = new.env(parent = baseenv()),
        quiet = TRUE
      )
      invisible(path)
    }
  ),
  private = list(
    results_df = NULL,
    configs_df = NULL,
    designs = NULL,
    cache_dir = NULL
  )
)

gstune_parse_args <- function(args) {
  args <- args[!vapply(args, is.null, logical(1))]

  if (!is.null(args$upper) && (!is.null(args$sfu) || !is.null(args$sfupar))) {
    stop("Specify either `upper=` or (`sfu`, `sfupar`), not both.", call. = FALSE)
  }
  if (!is.null(args$lower) && (!is.null(args$sfl) || !is.null(args$sflpar))) {
    stop("Specify either `lower=` or (`sfl`, `sflpar`), not both.", call. = FALSE)
  }

  tune_specs <- list()
  base_args <- list()

  if (!is.null(args$upper)) {
    settings <- as_spending_setting_list(args$upper)
    tune_specs$upper_setting <- tune_values(settings)
  }
  if (!is.null(args$lower)) {
    settings <- as_spending_setting_list(args$lower)
    tune_specs$lower_setting <- tune_values(settings)
  }

  args$upper <- NULL
  args$lower <- NULL

  for (nm in names(args)) {
    val <- args[[nm]]
    if (is_tune_spec(val)) {
      tune_specs[[nm]] <- val
    } else {
      base_args[[nm]] <- val
    }
  }

  ps <- ParamSpace$new()
  for (id in names(tune_specs)) {
    ps$add_param(id, tune_specs[[id]])
  }
  ps$validate(base_context = base_args)

  list(base_args = base_args, tune_specs = tune_specs, param_space = ps)
}

gstune_build_call_args <- function(base_args, tuned_args) {
  args <- base_args
  args[names(tuned_args)] <- tuned_args

  if (!is.null(args$upper_setting)) {
    us <- args$upper_setting
    args$sfu <- us$fun
    args$sfupar <- us$par
    args$upper_setting <- NULL
  }
  if (!is.null(args$lower_setting)) {
    ls <- args$lower_setting
    args$sfl <- ls$fun
    args$sflpar <- ls$par
    args$lower_setting <- NULL
  }
  args
}

gstune_spec_to_list <- function(x) {
  if (!is_tune_spec(x)) {
    return(list(type = "fixed", value = x))
  }
  x2 <- x
  x2$map <- NULL
  x2
}

gstune_add_derived_config_cols <- function(configs) {
  if (!is.data.frame(configs)) {
    return(configs)
  }
  if ("upper_setting" %in% names(configs)) {
    upper_fun <- vapply(configs$upper_setting, function(x) x$fun_label, character(1))
    upper_par <- lapply(configs$upper_setting, function(x) x$par)
    configs$upper_fun <- upper_fun
    configs$upper_par <- gstune_simplify_col(upper_par)
  }
  if ("lower_setting" %in% names(configs)) {
    lower_fun <- vapply(configs$lower_setting, function(x) x$fun_label, character(1))
    lower_par <- lapply(configs$lower_setting, function(x) x$par)
    configs$lower_fun <- lower_fun
    configs$lower_par <- gstune_simplify_col(lower_par)
  }
  configs
}

gstune_eval_design <- function(fn, args, config_id, target, base_args, tuned_args, metrics_fun) {
  warnings <- character()
  design <- NULL
  err <- NULL
  metrics_fun_error_message <- NA_character_
  design <- withCallingHandlers(
    tryCatch(
      do.call(fn, args),
      error = function(e) {
        err <<- e
        NULL
      }
    ),
    warning = function(w) {
      warnings <<- c(warnings, conditionMessage(w))
      invokeRestart("muffleWarning")
    }
  )

  status <- if (is.null(err)) "ok" else "error"
  error_message <- if (is.null(err)) NA_character_ else conditionMessage(err)

  cache_key <- gstune_cache_key(list(target = target, base_args = base_args), tuned_args = tuned_args)

  metrics <- list()
  if (identical(status, "ok")) {
    metrics <- tryCatch(
      gstune_extract_metrics(design, target = target),
      error = function(e) {
        err <<- e
        list()
      }
    )
    if (!is.null(err)) {
      status <- "error"
      error_message <- conditionMessage(err)
    }
    if (!is.null(metrics_fun)) {
      extra <- withCallingHandlers(
        tryCatch(
          metrics_fun(design, base_args, tuned_args),
          error = function(e) {
            metrics_fun_error_message <<- conditionMessage(e)
            NULL
          }
        ),
        warning = function(w) {
          warnings <<- c(warnings, conditionMessage(w))
          invokeRestart("muffleWarning")
        }
      )
      if (!is.null(extra)) {
        if (!is.list(extra) || is.null(names(extra)) || any(names(extra) == "")) {
          metrics_fun_error_message <- "`metrics_fun` must return a named list."
        } else {
          metrics[names(extra)] <- extra
        }
      }
    }
  }

  list(
    config_id = config_id,
    status = status,
    error_message = error_message,
    warnings = if (length(warnings) == 0L) NA_character_ else paste(unique(warnings), collapse = "\n"),
    metrics_fun_error_message = metrics_fun_error_message,
    call_args = args,
    cache_key = cache_key,
    design_rds = NA_character_,
    design = design,
    metrics = metrics
  )
}

gstune_cache_key <- function(base_blob, tuned_args) {
  raw <- serialize(list(base = base_blob, tuned = tuned_args), connection = NULL)
  gstune_md5_bytes(raw)
}

gstune_results_to_df <- function(results, configs) {
  out <- vector("list", length(results))

  for (i in seq_along(results)) {
    r <- results[[i]]
    row_index <- which(configs$config_id == r$config_id)[[1]]
    cfg_names <- setdiff(names(configs), "config_id")
    row_cfg <- stats::setNames(vector("list", length(cfg_names)), cfg_names)
    for (nm in cfg_names) {
      row_cfg[[nm]] <- configs[[nm]][[row_index]]
    }
    row <- c(
      row_cfg,
      list(
        config_id = r$config_id,
        status = r$status,
        error_message = r$error_message,
        warnings = r$warnings,
        cache_key = r$cache_key,
        design_rds = r$design_rds,
        call_args = r$call_args
      ),
      r$metrics
    )
    out[[i]] <- row
  }

  gstune_rows_to_df(out)
}

gstune_rows_to_df <- function(rows) {
  if (length(rows) == 0L) {
    return(data.frame())
  }
  all_names <- unique(unlist(lapply(rows, names), use.names = FALSE))
  cols <- stats::setNames(vector("list", length(all_names)), all_names)
  for (nm in all_names) {
    values <- lapply(rows, function(r) r[[nm]])
    # Try to simplify scalars, keep complex values as list-columns
    cols[[nm]] <- gstune_simplify_col(values)
  }
  as.data.frame(cols, stringsAsFactors = FALSE)
}

gstune_apply_constraints <- function(df, constraints) {
  if (is.null(constraints)) {
    return(df)
  }
  if (is.function(constraints)) {
    keep <- constraints(df)
    if (!is.logical(keep) || length(keep) != nrow(df)) {
      stop("`constraints(df)` must return a logical vector of length nrow(df).", call. = FALSE)
    }
    return(df[keep, , drop = FALSE])
  }
  if (is.character(constraints) && length(constraints) == 1L) {
    constraints <- parse(text = constraints)[[1]]
  }
  if (is.expression(constraints)) {
    constraints <- constraints[[1]]
  }
  if (is.call(constraints) || is.name(constraints)) {
    keep <- eval(constraints, envir = df, enclos = parent.frame())
    if (!is.logical(keep) || length(keep) != nrow(df)) {
      stop("`constraints` expression must evaluate to a logical vector of length nrow(df).", call. = FALSE)
    }
    return(df[keep, , drop = FALSE])
  }
  stop("`constraints` must be NULL, a function, or an expression/character string.", call. = FALSE)
}
