.gstune_fun_label_cache <- new.env(parent = emptyenv())

gstune_fun_label <- function(fun) {
  if (!is.function(fun)) {
    return("<not a function>")
  }

  key <- tryCatch(
    unname(tools::md5sum(bytes = serialize(fun, connection = NULL))),
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

gstune_label_list_col <- function(values) {
  vapply(values, gstune_label_value, character(1))
}

#' @noRd
#' @export
toString.function <- function(x, ...) {
  gstune_fun_label(x)
}
