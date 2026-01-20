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
