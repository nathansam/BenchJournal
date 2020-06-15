#' @title Find name of current package
#' @description Finds name of package being developed for by finding the current
#'     working directory and using the lowest level of the directory
#' @return String. The name of the package being developed
GetPkgName <- function() {
  # Working directory split into vector by folders
  wd.split <- unlist(strsplit(getwd(), "/"))
  # Select lowest level of directory
  pkg.name <- wd.split[length(wd.split)]
  return(pkg.name)
}

#' @title Create dataframe holding test results
#' @description Runs a script multiple times and returns the benchmark results
#'   for the runs.
#' @param script Name of the script (with .R extension)
#' @param times Number of times to benchmark script (not including warmup)
#' @param warmup  Number of times to run script first as a warmup
#' @param hash commit hash. Intended to be used only when using git hooks
#' @return A dataframe with columns for the script name, the time taken to run
#'   the script, the package version (or commit hash), the version of R, the
#'   date of the test, and the name of the system
CreateNewEntry <- function(script, times, warmup, hash) {
  script.location <- paste("man/BenchJournal/scripts/", script, sep = "")
  results <- microbenchmark::microbenchmark(source(script.location),
                                            times = times + 1)
  script <- as.character(strsplit(script, ".R"))
  time <- as.data.frame(results)$time
  if (is.null(hash)) {
    pkg.version <- rep(utils::packageVersion(GetPkgName()), times + 1)
  } else {
    pkg.version <- rep(hash, times + 1)
  }
  r.version <- rep(R.version.string, times + 1)
  test.date <- rep(Sys.Date(), times + 1)
  system.name <- rep(as.vector(Sys.info())[4], times + 1)

  entry <- data.frame(script,
                      time,
                      pkg.version,
                      r.version,
                      test.date,
                      system.name)

  for (i in 1:ncol(entry)) {
    entry[, i] <- as.character(entry[, i])
  }

  # Remove warmup runs. Inital runs are longer due to initial I/O operations
  entry <- entry[-warmup, ]
  return(entry)
}


#' @title Remove outliers from journal
#' @description Remove observations from a journal with outlier run times.
#' @param df dataframe in the format of journal
#' @return A dataframe where observations with outlier run times have been
#'   removed
RemoveOutliers <- function(df){
  index.non.outlier <- df[, "time"] %in% outliers::outlier(df[, "time"]) == FALSE
  # Remove rows with outliers
  df <- df[index.non.outlier, ]
  return(df)
}
