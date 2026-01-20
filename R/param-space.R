#' ParamSpace
#'
#' Internal R6 class to manage tuned parameters, candidate generation, and
#' dependencies for grid and random search.
#'
#' @field params Named list of tuned parameter specifications.
#' @field order Topologically sorted parameter IDs for dependency resolution.
#'
#' @param id Parameter ID (argument name).
#' @param spec Tuning specification (`tune_*()`).
#' @param depends_on Character vector of dependency names.
#' @param map Dependency mapping function.
#' @param base_context Named list of fixed values available for dependencies.
#' @param n Number of configurations to sample.
#' @param seed Optional seed for reproducible sampling.
#'
#' @keywords internal
ParamSpace <- R6::R6Class(
  "ParamSpace",
  public = list(
    params = NULL,
    order = NULL,
    #' @description
    #' Create a new parameter space.
    initialize = function() {
      self$params <- list()
      self$order <- character()
      invisible(self)
    },
    #' @description
    #' Add a tuned parameter specification.
    #'
    #' @param id Parameter ID (argument name).
    #' @param spec Tuning specification (`tune_*()`).
    add_param = function(id, spec) {
      if (!is.character(id) || length(id) != 1L || !nzchar(id)) {
        stop("`id` must be a non-empty character scalar.", call. = FALSE)
      }
      if (id %in% names(self$params)) {
        stop(sprintf("Parameter '%s' already exists in the space.", id), call. = FALSE)
      }
      if (!is_tune_spec(spec)) {
        spec <- tune_values(list(spec))
      }
      self$params[[id]] <- spec
      self$order <- names(self$params)
      invisible(self)
    },
    #' @description
    #' Set a dependency mapping for a tuned parameter.
    #'
    #' @param id Parameter ID to modify.
    #' @param depends_on Names that must be available in the context.
    #' @param map Mapping function returning a `tune_*()` spec or fixed value.
    set_dependency = function(id, depends_on, map) {
      if (!id %in% names(self$params)) {
        stop(sprintf("Unknown parameter '%s'.", id), call. = FALSE)
      }
      self$params[[id]] <- tune_dep(depends_on = depends_on, map = map)
      invisible(self)
    },
    #' @description
    #' Validate the space and compute dependency order.
    #'
    #' @param base_context Named list of fixed values available for dependencies.
    validate = function(base_context = list()) {
      if (!is.list(base_context)) {
        stop("`base_context` must be a list.", call. = FALSE)
      }
      ids <- names(self$params)
      if (length(ids) == 0L) {
        self$order <- character()
        return(invisible(self))
      }

      edges <- stats::setNames(vector("list", length(ids)), ids)
      indegree <- stats::setNames(integer(length(ids)), ids)

      for (id in ids) {
        spec <- self$params[[id]]
        if (is_tune_spec(spec) && identical(spec$type, "dep")) {
          deps <- spec$depends_on
          missing_deps <- deps[!(deps %in% ids) & !(deps %in% names(base_context))]
          if (length(missing_deps) > 0L) {
            stop(
              sprintf(
                "Parameter '%s' depends on missing names: %s",
                id,
                paste(missing_deps, collapse = ", ")
              ),
              call. = FALSE
            )
          }
          tuned_deps <- intersect(deps, ids)
          if (length(tuned_deps) > 0L) {
            for (d in tuned_deps) {
              edges[[d]] <- unique(c(edges[[d]], id))
              indegree[[id]] <- indegree[[id]] + 1L
            }
          }
        } else {
          # Basic sanity: independent specs should have at least one candidate
          cand <- gstune_candidates(spec, context = base_context)
          if (length(cand) == 0L) {
            stop(sprintf("Parameter '%s' has no candidates.", id), call. = FALSE)
          }
        }
      }

      order <- character()
      queue <- ids[indegree == 0L]
      # keep deterministic order based on insertion order
      queue <- queue[order(match(queue, ids))]

      while (length(queue) > 0L) {
        node <- queue[[1]]
        queue <- queue[-1]
        order <- c(order, node)
        for (child in edges[[node]]) {
          indegree[[child]] <- indegree[[child]] - 1L
          if (indegree[[child]] == 0L) {
            queue <- c(queue, child)
            queue <- queue[order(match(queue, ids))]
          }
        }
      }

      if (length(order) != length(ids)) {
        stop("Detected cyclic dependencies in tuned parameters.", call. = FALSE)
      }

      self$order <- order
      invisible(self)
    },
    #' @description
    #' Generate a dependency-aware Cartesian product (grid).
    #'
    #' @param base_context Named list of fixed values available for dependencies.
    grid = function(base_context = list()) {
      self$validate(base_context = base_context)
      ids <- self$order
      if (length(ids) == 0L) {
        df <- data.frame(stringsAsFactors = FALSE)
        return(df[1, , drop = FALSE])
      }

      configs <- list()
      walk <- function(i, context) {
        if (i > length(ids)) {
          configs[[length(configs) + 1L]] <<- context
          return(invisible(NULL))
        }
        id <- ids[[i]]
        spec <- self$params[[id]]
        cand <- gstune_candidates(spec, context = context)
        for (v in cand) {
          context2 <- context
          context2[id] <- list(v)
          walk(i + 1L, context2)
        }
        invisible(NULL)
      }

      walk(1L, base_context)
      gstune_configs_to_df(configs, ids)
    },
    #' @description
    #' Sample configurations at random.
    #'
    #' @param n Number of configurations to sample.
    #' @param base_context Named list of fixed values available for dependencies.
    #' @param seed Optional seed for reproducible sampling.
    sample_random = function(n, base_context = list(), seed = NULL) {
      if (!is.numeric(n) || length(n) != 1L || n < 1L) {
        stop("`n` must be a positive integer.", call. = FALSE)
      }
      n <- as.integer(n)
      if (!is.null(seed)) {
        if (!is.numeric(seed) || length(seed) != 1L) {
          stop("`seed` must be a numeric scalar.", call. = FALSE)
        }
        set.seed(as.integer(seed))
      }

      self$validate(base_context = base_context)
      ids <- self$order
      if (length(ids) == 0L) {
        df <- data.frame(stringsAsFactors = FALSE)
        return(df[rep(1L, n), , drop = FALSE])
      }

      configs <- vector("list", n)
      for (i in seq_len(n)) {
        context <- base_context
        for (id in ids) {
          spec <- self$params[[id]]
          cand <- gstune_candidates(spec, context = context)
          context[id] <- list(cand[[sample.int(length(cand), size = 1L)]])
        }
        configs[[i]] <- context
      }

      gstune_configs_to_df(configs, ids)
    }
  )
)

#' Convert configuration list to a data.frame
#'
#' @param configs List of named lists (contexts), one per configuration.
#' @param ids Character vector of tuned parameter IDs (column order).
#'
#' @return A data.frame of configurations; complex values are stored as
#'   list-columns.
#'
#' @noRd
gstune_configs_to_df <- function(configs, ids) {
  n <- length(configs)
  cols <- stats::setNames(vector("list", length(ids)), ids)
  for (id in ids) {
    values <- lapply(configs, `[[`, id)
    cols[[id]] <- gstune_simplify_col(values)
  }
  as.data.frame(cols, stringsAsFactors = FALSE)
}

#' Simplify column values for results/config tables
#'
#' Attempts to simplify a list of values into an atomic vector when every value
#' is a scalar atomic. Otherwise returns an `I()` list-column.
#'
#' @param values List of values.
#'
#' @return An atomic vector or an `I()` list-column.
#'
#' @noRd
gstune_simplify_col <- function(values) {
  if (length(values) == 0L) {
    return(values)
  }
  is_scalar_atomic <- vapply(
    values,
    function(x) is.atomic(x) && length(x) == 1L && is.null(dim(x)),
    logical(1)
  )
  if (all(is_scalar_atomic)) {
    return(unlist(values, use.names = FALSE))
  }
  I(values)
}
