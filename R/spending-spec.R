#' Spending function specifications
#'
#' `SpendingSpec` and `SpendingFamily` provide a dependency-aware and
#' user-friendly way to tune spending functions and their parameters.
#'
#' @name spending_specs
NULL

#' SpendingSpec
#'
#' An R6 class representing a single spending function (`fun`) and a tuning
#' specification for its parameter (`par`).
#'
#' @field fun Spending function (callable with signature `(alpha, t, param)`).
#' @field fun_label Label captured from the constructor call (used for plotting).
#' @field par Tuning specification for the spending parameter.
#'
#' @param fun Spending function.
#' @param par Spending parameter specification (fixed value or `tune_*()` spec).
#'
#' @export
SpendingSpec <- R6::R6Class(
  "SpendingSpec",
  public = list(
    fun = NULL,
    fun_label = NULL,
    par = NULL,
    #' @description
    #' Create a new spending specification.
    #'
    #' @param fun Spending function.
    #' @param par Spending parameter specification.
    initialize = function(fun, par = tune_fixed(NULL)) {
      fun_expr <- substitute(fun)
      fun_value <- eval(fun_expr, parent.frame())
      if (!is.function(fun_value)) {
        stop("`fun` must be a function.", call. = FALSE)
      }
      if (!is_tune_spec(par)) {
        par <- tune_fixed(par)
      }

      self$fun <- fun_value
      self$fun_label <- paste(deparse(fun_expr), collapse = "")
      self$par <- par
      invisible(self)
    },
    #' @description
    #' Expand to a list of spending settings (fun + concrete parameter values).
    expand = function() {
      pars <- gstune_candidates(self$par, context = list())
      lapply(
        pars,
        function(p) {
          spending_setting(fun = self$fun, fun_label = self$fun_label, par = p)
        }
      )
    }
  )
)

#' SpendingFamily
#'
#' An R6 class representing a set of spending function specifications. Each
#' family member is a `SpendingSpec`.
#'
#' @field members List of `SpendingSpec` objects.
#'
#' @param ... One or more `SpendingSpec` objects.
#'
#' @export
SpendingFamily <- R6::R6Class(
  "SpendingFamily",
  public = list(
    members = NULL,
    #' @description
    #' Create a new spending family from one or more `SpendingSpec`.
    #'
    #' @param ... `SpendingSpec` objects.
    initialize = function(...) {
      members <- list(...)
      if (length(members) == 0L) {
        stop("`SpendingFamily$new()` requires at least one `SpendingSpec`.", call. = FALSE)
      }
      ok <- vapply(members, function(x) inherits(x, "SpendingSpec"), logical(1))
      if (!all(ok)) {
        stop("All `SpendingFamily` members must be `SpendingSpec` objects.", call. = FALSE)
      }
      self$members <- members
      invisible(self)
    },
    #' @description
    #' Expand all members to spending settings.
    expand = function() {
      unlist(lapply(self$members, function(x) x$expand()), recursive = FALSE)
    }
  )
)

spending_setting <- function(fun, fun_label, par) {
  structure(list(fun = fun, fun_label = fun_label, par = par), class = "gstune_spending")
}

is_spending_setting <- function(x) {
  inherits(x, "gstune_spending")
}

as_spending_setting_list <- function(x) {
  if (inherits(x, "SpendingSpec")) {
    return(x$expand())
  }
  if (inherits(x, "SpendingFamily")) {
    return(x$expand())
  }
  if (is_spending_setting(x)) {
    return(list(x))
  }
  stop("Expected a `SpendingSpec`, `SpendingFamily`, or spending setting.", call. = FALSE)
}
