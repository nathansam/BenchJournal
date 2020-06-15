test_that("RemoveOutliers works correctly", {
  #Example journal entry
  entry <- data.frame(script = rep("hmm.R", 10),
                      time = c(1, 2, 3, 2, 1, 3, 4, 5 ,8, 100),
                      pkg.version = rep("0.0.2", 10),
                      r.version = rep ("4.0.0", 10),
                      test.date = rep(Sys.Date(), 10),
                      system.name = rep("bob", 10))
  entry2 <- RemoveOutliers(entry)
  expect_equal(entry[1:9, ], entry2)
})
