test_that("Known gsDesign metrics are stable (snapshot)", {
  job <- gsDesignTune(
    k = 3,
    test.type = 2,
    alpha = 0.025,
    beta = 0.10
  )
  job$run(strategy = "grid", parallel = FALSE)
  res <- job$results()

  snap <- list(
    final_n = round(res$final_n[[1]], 4),
    upper_z1 = round(res$upper_z1[[1]], 4),
    power = round(res$power[[1]], 4)
  )

  expect_snapshot_value(snap, style = "json2")
})
