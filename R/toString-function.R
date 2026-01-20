.gstune_fun_label_cache <- new.env(parent = emptyenv())

#' Label a function for printing and plotting
#'
#' Creates a short label for a function (preferably `pkg::name`) and caches the
#' result to keep printing/plotting fast when function-valued columns are used.
#'
#' @param fun A function.
#'
#' @return A character scalar.
#'
#' @noRd
gstune_fun_label <- function(fun) {
  if (!is.function(fun)) {
    return("<not a function>")
  }

  key <- tryCatch(
    gstune_md5_bytes(serialize(fun, connection = NULL)),
    error = function(e) NA_character_
  )

  if (!is.na(key) && exists(key, envir = .gstune_fun_label_cache, inherits = FALSE)) {
    return(get(key, envir = .gstune_fun_label_cache, inherits = FALSE))
  }

  label <- gstune_fun_label_uncached(fun)

  if (!is.na(key)) {
    assign(key, label, envir = .gstune_fun_label_cache)
  }

  label
}

#' Compute an uncached function label
#'
#' @param fun A function.
#'
#' @return A character scalar.
#'
#' @noRd
gstune_fun_label_uncached <- function(fun) {
  env <- environment(fun)
  if (is.null(env)) {
    return("<function>")
  }
  if (isNamespace(env)) {
    ns <- sub("^namespace:", "", environmentName(env))
    nm <- gstune_find_name_in_env(fun, env)
    if (!is.na(nm)) {
      return(paste0(ns, "::", nm))
    }
    return(paste0(ns, "::", "<function>"))
  }
  "<function>"
}

#' Find an object's name in an environment
#'
#' Used to label functions from namespace environments.
#'
#' @param obj Object to locate.
#' @param env Environment to search.
#'
#' @return A character scalar name, or `NA_character_` if not found.
#'
#' @noRd
gstune_find_name_in_env <- function(obj, env) {
  nms <- tryCatch(ls(env, all.names = TRUE), error = function(e) character())
  for (nm in nms) {
    val <- tryCatch(get0(nm, envir = env, inherits = FALSE), error = function(e) NULL)
    if (identical(val, obj)) {
      return(nm)
    }
  }
  NA_character_
}

#' Create a short label for a value
#'
#' Handles spending settings, functions, and scalars, with a `toString()`-based
#' fallback for other values.
#'
#' @param x Value to label.
#'
#' @return A character scalar.
#'
#' @noRd
gstune_label_value <- function(x) {
  if (is_spending_setting(x)) {
    par <- x$par
    par_txt <- if (is.null(par)) "NULL" else tryCatch(toString(par), error = function(e) "<par>")
    return(paste0(x$fun_label, " (par=", par_txt, ")"))
  }
  if (is.function(x)) {
    return(gstune_fun_label(x))
  }
  if (is.atomic(x) && length(x) == 1L && is.null(dim(x))) {
    return(as.character(x))
  }
  tryCatch(toString(x), error = function(e) "<value>")
}

#' Label each element of a list-column
#'
#' @param values List of values.
#'
#' @return A character vector.
#'
#' @noRd
gstune_label_list_col <- function(values) {
  vapply(values, gstune_label_value, character(1))
}

#' @noRd
#' @export
toString.function <- function(x, ...) {
  gstune_fun_label(x)
}
