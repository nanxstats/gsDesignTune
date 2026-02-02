#' Tune specifications
#'
#' `gsDesignTune()` and `gsSurvTune()` treat most arguments as fixed values.
#' Wrap an argument in a `tune_*()` specification to explore candidate values.
#'
#' @name tune_specs
NULL

#' Fixed (non-tuned) value
#'
#' Use `tune_fixed()` to explicitly mark a value as fixed. This is mainly useful
#' inside dependent specifications such as `tune_dep()`.
#'
#' @param x Any R object.
#'
#' @return A `gstune_spec` object.
#'
#' @export
#'
#' @examples
#' tune_fixed(0.025)
tune_fixed <- function(x) {
  structure(
    list(type = "fixed", value = x, call = match.call()),
    class = "gstune_spec"
  )
}

#' Explicit candidate values
#'
#' `tune_values()` defines a finite set of candidate values.
#' Values are provided as a list so vector-valued candidates
#' (for example, `timing`) are treated as atomic.
#'
#' @param values A list of candidate values.
#'
#' @return A `gstune_spec` object.
#'
#' @export
#'
#' @examples
#' tune_values(list(0.55, 0.65, 0.75))
#' tune_values(list(c(0.33, 0.67, 1), c(0.5, 0.75, 1)))
tune_values <- function(values) {
  if (!is.list(values)) {
    stop("`values` must be a list (use `list(...)`).", call. = FALSE)
  }
  if (length(values) == 0L) {
    stop("`values` must not be empty.", call. = FALSE)
  }
  structure(
    list(type = "values", values = values, call = match.call()),
    class = "gstune_spec"
  )
}

#' Numeric sequence candidates
#'
#' @param from,to Numeric scalars.
#' @param length_out Integer scalar, the number of candidates.
#'
#' @return A `gstune_spec` object.
#'
#' @export
#'
#' @examples
#' tune_seq(0.55, 0.75, length_out = 5)
tune_seq <- function(from, to, length_out) {
  if (!is.numeric(from) || length(from) != 1L || !is.finite(from)) {
    stop("`from` must be a finite numeric scalar.", call. = FALSE)
  }
  if (!is.numeric(to) || length(to) != 1L || !is.finite(to)) {
    stop("`to` must be a finite numeric scalar.", call. = FALSE)
  }
  if (!is.numeric(length_out) || length(length_out) != 1L || length_out < 1L) {
    stop("`length_out` must be a positive integer.", call. = FALSE)
  }
  length_out <- as.integer(length_out)
  structure(
    list(type = "seq", from = from, to = to, length_out = length_out, call = match.call()),
    class = "gstune_spec"
  )
}

#' Integer sequence candidates
#'
#' @param from,to Integer scalars.
#' @param by Integer scalar step size.
#'
#' @return A `gstune_spec` object.
#'
#' @export
#'
#' @examples
#' tune_int(2, 5)
tune_int <- function(from, to, by = 1) {
  if (!is.numeric(from) || length(from) != 1L || !is.finite(from)) {
    stop("`from` must be a finite numeric scalar.", call. = FALSE)
  }
  if (!is.numeric(to) || length(to) != 1L || !is.finite(to)) {
    stop("`to` must be a finite numeric scalar.", call. = FALSE)
  }
  if (!is.numeric(by) || length(by) != 1L || !is.finite(by) || by == 0) {
    stop("`by` must be a non-zero numeric scalar.", call. = FALSE)
  }
  structure(
    list(type = "int", from = as.integer(from), to = as.integer(to), by = as.integer(by), call = match.call()),
    class = "gstune_spec"
  )
}

#' Categorical choices
#'
#' `tune_choice()` defines a finite set of categorical choices. Each argument in
#' `...` is treated as one choice (including functions and other objects).
#'
#' @param ... Candidate values.
#'
#' @return A `gstune_spec` object.
#'
#' @export
#'
#' @examples
#' tune_choice("A", "B")
tune_choice <- function(...) {
  values <- list(...)
  tune_values(values)
}

#' Dependent tuning specification
#'
#' `tune_dep()` defines candidates for one argument as a function of other
#' arguments.
#'
#' @param depends_on Character vector of argument names this specification
#'   depends on.
#' @param map A function returning either a `tune_*()` specification or
#'   a fixed value. The function should have arguments matching
#'   `depends_on` (or use `...`).
#'
#' @return A `gstune_spec` object.
#'
#' @export
#'
#' @examples
#' # sfupar depends on sfu
#' tune_dep(
#'   depends_on = "sfu",
#'   map = function(sfu) {
#'     if (identical(sfu, gsDesign::sfLDOF)) tune_fixed(0) else tune_seq(-4, 4, 9)
#'   }
#' )
tune_dep <- function(depends_on, map) {
  if (!is.character(depends_on) || length(depends_on) < 1L) {
    stop("`depends_on` must be a non-empty character vector.", call. = FALSE)
  }
  if (!is.function(map)) {
    stop("`map` must be a function.", call. = FALSE)
  }
  structure(
    list(type = "dep", depends_on = unique(depends_on), map = map, call = match.call()),
    class = "gstune_spec"
  )
}

#' Check if an object is a tune specification
#'
#' @param x Any R object.
#'
#' @return Logical scalar.
#'
#' @noRd
is_tune_spec <- function(x) {
  inherits(x, "gstune_spec")
}

#' Resolve a tuning spec into candidate values
#'
#' Expands `tune_*()` specifications into a list of concrete candidate values.
#' Dependent specifications (`tune_dep()`) are resolved using `context`.
#'
#' @param spec A `gstune_spec` or fixed value.
#' @param context Named list of already-resolved values used for `tune_dep()`.
#'
#' @return A list of candidate values (each element is one atomic setting).
#'
#' @noRd
gstune_candidates <- function(spec, context) {
  if (!is_tune_spec(spec)) {
    return(list(spec))
  }
  type <- spec$type %||% NA_character_
  switch(type,
    fixed = list(spec$value),
    values = spec$values,
    seq = as.list(seq(from = spec$from, to = spec$to, length.out = spec$length_out)),
    int = as.list(seq.int(from = spec$from, to = spec$to, by = spec$by)),
    dep = {
      deps <- spec$depends_on
      missing_deps <- deps[!deps %in% names(context)]
      if (length(missing_deps) > 0L) {
        stop(
          sprintf(
            "Cannot resolve dependent spec; missing values for: %s",
            paste(missing_deps, collapse = ", ")
          ),
          call. = FALSE
        )
      }
      dep_values <- context[deps]
      resolved <- tryCatch(
        do.call(spec$map, dep_values),
        error = function(e) {
          stop(sprintf("Failed to resolve dependent spec: %s", conditionMessage(e)), call. = FALSE)
        }
      )
      if (is_tune_spec(resolved)) {
        gstune_candidates(resolved, context)
      } else {
        list(resolved)
      }
    },
    stop(sprintf("Unknown tune spec type: %s", type), call. = FALSE)
  )
}

#' Null-coalescing operator
#'
#' @param x,y Objects.
#'
#' @return `x` if it is not `NULL`, otherwise `y`.
#'
#' @noRd
`%||%` <- function(x, y) {
  if (is.null(x)) y else x
}
