test_that("ParamSpace grid produces Cartesian product", {
  ps <- gsDesignTune:::ParamSpace$new()
  ps$add_param("a", tune_values(list(1, 2)))
  ps$add_param("b", tune_values(list("x", "y")))
  grid <- ps$grid(base_context = list())

  expect_equal(nrow(grid), 4)
  expect_equal(sort(unique(grid$a)), c(1, 2))
  expect_equal(sort(unique(grid$b)), c("x", "y"))
})

test_that("Vector-valued candidates are treated as atomic", {
  ps <- gsDesignTune:::ParamSpace$new()
  ps$add_param("timing", tune_values(list(c(0.33, 0.67, 1), c(0.5, 0.75, 1))))
  grid <- ps$grid(base_context = list())

  expect_equal(nrow(grid), 2)
  expect_true(is.list(grid$timing))
  expect_equal(grid$timing[[1]], c(0.33, 0.67, 1))
})
