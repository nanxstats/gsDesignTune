gstune_extract_metrics <- function(design, target = c("gsDesign", "gsSurv")) {
  target <- match.arg(target)

  bs <- tryCatch(gsDesign::gsBoundSummary(design), error = function(e) NULL)
  z_rows <- NULL
  p_rows <- NULL
  if (!is.null(bs)) {
    z_rows <- bs[bs$Value == "Z", , drop = FALSE]
    p_rows <- bs[bs$Value == "p (1-sided)", , drop = FALSE]
  }

  k <- design$k %||% NA_integer_
  n_I <- design$n.I %||% NULL

  upper_bound <- if (!is.null(design$upper)) design$upper$bound else NULL
  lower_bound <- if (!is.null(design$lower)) design$lower$bound else NULL
  upper_z <- if (!is.null(z_rows)) z_rows$Efficacy else upper_bound %||% NA_real_
  lower_z <- if (!is.null(z_rows)) z_rows$Futility else lower_bound %||% NA_real_
  upper_p <- if (!is.null(p_rows)) p_rows$Efficacy else NA_real_
  lower_p <- if (!is.null(p_rows)) p_rows$Futility else NA_real_

  power <- NA_real_
  if (!is.null(design$upper) && !is.null(design$upper$prob) && ncol(design$upper$prob) >= 2L) {
    power <- sum(design$upper$prob[, 2], na.rm = TRUE)
  }

  upper_name <- NA_character_
  lower_name <- NA_character_
  if (!is.null(design$upper) && !is.null(design$upper$name)) upper_name <- design$upper$name
  if (!is.null(design$lower) && !is.null(design$lower$name)) lower_name <- design$lower$name

  metrics <- list(
    k = k,
    test.type = design$test.type %||% NA_integer_,
    alpha = design$alpha %||% NA_real_,
    beta = design$beta %||% NA_real_,
    timing = design$timing %||% NULL,
    n_I = n_I,
    final_n_I = if (!is.null(n_I) && length(n_I) > 0L) n_I[[length(n_I)]] else NA_real_,
    upper_z = upper_z,
    lower_z = lower_z,
    upper_p = upper_p,
    lower_p = lower_p,
    power = power,
    en = design$en %||% NULL,
    upper_name = upper_name,
    lower_name = lower_name,
    bound_summary = bs
  )

  if (target == "gsSurv") {
    n_total <- NULL
    if (!is.null(p_rows)) {
      n_total <- suppressWarnings(as.numeric(sub(".*N:\\s*", "", p_rows$Analysis)))
    }
    metrics$final_events <- metrics$final_n_I
    metrics$max_events <- if (!is.null(n_I)) max(n_I, na.rm = TRUE) else NA_real_
    metrics$n_total <- n_total
    metrics$final_n_total <- if (!is.null(n_total) && length(n_total) > 0L) n_total[[length(n_total)]] else NA_real_
    metrics$analysis_time <- design$T %||% NULL
  } else {
    metrics$final_n <- metrics$final_n_I
    metrics$max_n <- if (!is.null(n_I)) max(n_I, na.rm = TRUE) else NA_real_
  }

  metrics$upper_z1 <- if (!is.null(upper_z) && length(upper_z) > 0L) upper_z[[1]] else NA_real_
  metrics$lower_z1 <- if (!is.null(lower_z) && length(lower_z) > 0L) lower_z[[1]] else NA_real_

  metrics
}
