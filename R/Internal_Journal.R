GetPkgName <- function() {
  # Working directory split into vector by folders
  wd.split <- unlist(strsplit(getwd(), "/"))
  # Select lowest level of directory
  pkg.name <- wd.split[length(wd.split)]
  return(pkg.name)
}


CreateNewEntry <- function(script, times, warmup) {
  script.location <- paste("man/BenchJournal/scripts/", script, sep = "")
  results <- microbenchmark::microbenchmark(source(script.location),
                                            times = times + 1)

  script <- as.character(strsplit(script, ".R"))
  time <- as.data.frame(results)$time
  pkg.version <- rep(utils::packageVersion(GetPkgName()), times + 1)
  r.version <- rep(R.version.string, times + 1)
  test.date <- rep(Sys.Date(), times + 1)
  system.name <- rep(as.vector(Sys.info())[4], times + 1)

  entry <- data.frame(script, time, pkg.version, r.version, test.date,
                      system.name)

  for (i in 1:ncol(entry)) {
    entry[, i] <- as.character(entry[, i])
  }

  # Remove warmup runs. Inital runs are longer due to I/O operations
  entry <- entry[-warmup, ]

  return(entry)
}
