test_that("tune_dep enforces dependencies in grid generation", {
  ps <- gsDesignTune:::ParamSpace$new()
  ps$add_param("sfu", tune_choice("A", "B"))
  ps$add_param(
    "sfupar",
    tune_dep(
      depends_on = "sfu",
      map = function(sfu) {
        if (sfu == "A") tune_values(list(0)) else tune_values(list(1, 2))
      }
    )
  )
  grid <- ps$grid(base_context = list())

  expect_equal(nrow(grid), 3)
  expect_equal(grid$sfupar[grid$sfu == "A"], 0)
  expect_equal(sort(grid$sfupar[grid$sfu == "B"]), c(1, 2))
})

test_that("ParamSpace validate detects missing dependencies", {
  ps <- gsDesignTune:::ParamSpace$new()
  ps$add_param("b", tune_dep(depends_on = "a", map = function(a) 1))
  expect_error(ps$validate(base_context = list()), "depends on missing names")
})
