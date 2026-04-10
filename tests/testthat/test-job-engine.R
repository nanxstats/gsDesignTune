test_that("Job captures errors per configuration", {
  job <- gsDesignTune(
    k = tune_values(list(-1, 3)),
    test.type = 2,
    alpha = 0.025,
    beta = 0.10
  )
  job$run(strategy = "grid", parallel = FALSE)
  res <- job$results()

  expect_equal(nrow(res), 2)
  expect_true(any(res$status == "error"))
  expect_true(any(res$status == "ok"))
  expect_true(any(!is.na(res$error_message[res$status == "error"])))
})

test_that("Parallel and sequential runs match on metrics", {
  testthat::skip_if_not_installed("future")
  testthat::skip_if_not_installed("future.apply")

  job1 <- gsDesignTune(
    k = 3,
    test.type = 2,
    alpha = 0.025,
    beta = 0.10,
    timing = tune_values(list(c(0.33, 0.67, 1), c(0.5, 0.75, 1)))
  )

  future::plan(future::sequential)
  job1$run(strategy = "grid", parallel = FALSE)
  res1 <- job1$results()

  job2 <- gsDesignTune(
    k = 3,
    test.type = 2,
    alpha = 0.025,
    beta = 0.10,
    timing = tune_values(list(c(0.33, 0.67, 1), c(0.5, 0.75, 1)))
  )

  plan_old <- future::plan()
  on.exit(future::plan(plan_old), add = TRUE)
  tryCatch(
    future::plan(future::multicore, workers = 1),
    error = function(e) testthat::skip("No supported parallel future backend in this environment.")
  )
  job2$run(strategy = "grid", parallel = TRUE, seed = 1)
  res2 <- job2$results()

  # drop call_args to avoid cross-process function serialization differences
  res1$call_args <- NULL
  res2$call_args <- NULL
  expect_equal(res1, res2)
})

test_that("Call reconstruction reproduces a design", {
  job <- gsDesignTune(
    k = 3,
    test.type = 2,
    alpha = 0.025,
    beta = 0.10,
    timing = tune_values(list(c(0.33, 0.67, 1), c(0.5, 0.75, 1)))
  )
  job$run(strategy = "grid", parallel = FALSE)

  d1 <- job$design(1)
  d2 <- do.call(gsDesign::gsDesign, job$call_args(1))

  expect_equal(d1$n.I, d2$n.I)
  expect_equal(d1$upper$bound, d2$upper$bound)
})

test_that("gsSurvCalendarTune runs and reconstructs calls", {
  job <- gsSurvCalendarTune(
    test.type = 4,
    alpha = 0.025,
    beta = 0.10,
    calendarTime = tune_values(list(c(12, 24, 36), c(9, 18, 27))),
    spending = tune_choice("information", "calendar"),
    hr = tune_values(list(0.70, 0.75)),
    sfl = gsDesign::sfLDPocock,
    sflpar = NULL,
    lambdaC = log(2) / 6,
    eta = 0.01,
    gamma = c(2.5, 5, 7.5, 10),
    R = c(2, 2, 2, 6),
    minfup = 18,
    ratio = 1
  )
  job$run(strategy = "grid", parallel = FALSE)
  res <- job$results()

  expect_true(all(res$status %in% c("ok", "error")))
  expect_true(any(res$status == "ok"))
  expect_true("final_events" %in% names(res))

  # Reconstruct the underlying call for one successful configuration
  ok_i <- which(res$status == "ok")[[1]]
  d1 <- job$design(ok_i)
  call_args <- job$call_args(ok_i)
  expect_true("sflpar" %in% names(call_args))
  expect_true(is.null(call_args$sflpar))
  d2 <- do.call(gsDesign::gsSurvCalendar, call_args)

  expect_equal(d1$n.I, d2$n.I)
  expect_equal(d1$upper$bound, d2$upper$bound)
  expect_equal(d1$T, d2$T)
})

test_that("Table rendering returns a compact tinytable", {
  job <- gsDesignTune(
    k = 3,
    test.type = 2,
    alpha = 0.025,
    beta = 0.10,
    timing = tune_values(list(c(0.33, 0.67, 1), c(0.5, 0.75, 1)))
  )
  job$run(strategy = "grid", parallel = FALSE)

  tab <- job$table(n = 1)
  expect_s4_class(tab, "tinytable")

  df <- tinytable::save_tt(tab, output = "dataframe")
  header <- trimws(gsub("*", "", unlist(df[1, ]), fixed = TRUE))
  expect_true(any(grepl("^Config ID$", header)))
  expect_true(any(grepl("^Timing$", header)))
  expect_true(any(grepl("^Final N$", header)))
  expect_false(any(grepl("^Call args$", header)))
  expect_false(any(grepl("^Cache key$", header)))
  expect_false(any(grepl("^Bound summary$", header)))
  expect_false(any(grepl("^Status$", header)))
})

test_that("Table rendering supports Pareto results", {
  job <- gsSurvTune(
    k = 3,
    test.type = 4,
    alpha = 0.025,
    beta = 0.10,
    timing = tune_values(list(c(0.33, 0.67, 1), c(0.5, 0.75, 1))),
    hr = tune_values(list(0.60, 0.65)),
    upper = SpendingFamily$new(
      SpendingSpec$new(sfLDOF, par = tune_fixed(0)),
      SpendingSpec$new(sfHSD, par = tune_values(list(-2, 0)))
    ),
    lower = SpendingSpec$new(sfLDOF, par = tune_fixed(0)),
    lambdaC = log(2) / 6,
    eta = 0.01,
    gamma = c(2.5, 5, 7.5, 10),
    R = c(2, 2, 2, 6),
    T = 18,
    minfup = 6,
    ratio = 1
  )
  job$run(strategy = "grid", parallel = FALSE)

  pareto <- job$pareto(metrics = c("final_events", "upper_z1"), directions = c("min", "min"))
  tab <- job$table(pareto, n = 5)
  expect_s4_class(tab, "tinytable")

  df <- tinytable::save_tt(tab, output = "dataframe")
  header <- trimws(gsub("*", "", unlist(df[1, ]), fixed = TRUE))
  expect_true(any(grepl("^Final events$", header)))
  expect_true(any(grepl("^Upper Z \\(IA1\\)$", header)))
  expect_false(any(grepl("^Call args$", header)))
  expect_false(any(grepl("^Bound summary$", header)))
})
