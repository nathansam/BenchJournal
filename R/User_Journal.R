#' @title Create folders in /man required for BenchJournal
#' @description  Sets up a \code{BenchmarkJournal} subdirectory in the
#'     \code{/man} directory. Inside this subdirectory, a csv file is created to
#'     hold the benchmark results and two additional folders. One for holding
#'     scripts to be benchmarked, called \code{scripts}. and one to hold plots,
#'     helpfully called \code{plots}.The \code{BenchmarkJournal} subdirectory is
#'     also added to .Rbuildignore. The user is asked if they wish to use the
#'     githook workflow or manually run \link{NewEntry}
#' @export
Init <- function() {

  if (dir.exists("man/BenchJournal")) {
    stop("Folders for BenchJournal have already been created!")
  }

  dir.create("man/BenchJournal")
  dir.create("man/BenchJournal/scripts")
  dir.create("man/BenchJournal/plots")

  NewJournal()

  usethis::use_build_ignore("man/BenchJournal")

  use.hook <- readline(prompt = "Update your journal automatically? Y/n ")

  if (tolower(use.hook) %in% c("y", "yes", "YES", "Y")) {

    usethis::use_git_hook("pre-push",
    "#!/bin/sh
    hashID=$(git rev-parse --short=7 HEAD)
    Rscript -e 'BenchJournal::NewEntry(hash = commandArgs(T)[1])' $hashID
    git add man/BenchJournal/journal.csv
    git commit -m 'Update BenchJournal file' --no-verify"
    )

    cat("Updating automatically with every git push \n")
  } else{
    cat("Updating manually instead. \n")
    cat("Manually run NewEntry() to update the journal. \n")
  }
}

#' @title Create a new journal file
#' @description Creates a new csv file to journal benchmark results, overwriting
#' the previous results. The user is asked to confirm overwriting an existing
#' file unless ask != TRUE
#' @param ask Logical. If TRUE then the user is asked to confirm overwriting
#'  the journal csv file.
#' @export
NewJournal <- function(ask = TRUE) {

  if (ask == TRUE & file.exists("man/BenchJournal/journal.csv")) {
    input <- readline("Overwrite the journal which already exists? ")

    if (tolower(input) %in% c("y", "yes") == F) {
      stop("Not overwriting the journal")
    }
  }

    # else overwrite journal
    journal <- data.frame(script = character(0),
                          time = character(0),
                          pkg.version = character(0),
                          r.version = character(0),
                          test.date = character(0),
                          system.name = character(0))
    utils::write.csv(journal, "man/BenchJournal/journal.csv", row.names = F)
}




#' @title Create new entry of benchmark results in the journal.
#' @description Uses \code{microbenchmark} to benchmark the scripts in
#' man/BenchJournal/scripts and then adds the results to the journal file.
#' @param times The number of times to benchmark each script.
#' @param warmup The warmup period. Defaults to 2. The first runs are typically
#'   much slower than the remaining runs due to the I/O operations invovled when
#'   reading the script(s). As such, using a warmup period is strongly advised.
#'   Bear in mind the total number of runs will be times + warmup, so a high
#'   value for warmup is not advised.
#' @param hash The hash for a git committ. Used when the git hook workflow
#'   is being used. If you are a human, leave this as \code{NULL}.
#' @export
NewEntry <- function(times = 10, warmup = 2, hash = NULL) {
  scripts <- dir("man/BenchJournal/scripts")

  pkg.name <- GetPkgName()

  if (length(scripts) == 0) {
    stop("No R scripts found in man/BenchJournal/scripts")
  }
  journal <- utils::read.csv("man/BenchJournal/journal.csv", row.names = NULL,
                             stringsAsFactors = FALSE)
  journal$pkg.version <- as.vector(journal$pkg.version)
  journal$test.date <- as.vector(journal$test.date)

  if (as.character(utils::packageVersion(GetPkgName())) %in% unique(journal[, 3])) {
    cat("Benchmark results have already been recorded for this version of ",
        pkg.name,
        " (",
        utils::packageVersion(GetPkgName()),
        ")\n")
  } else{
    for (script in scripts) {
      new.entry <- CreateNewEntry(script, times, warmup, hash)
      journal <- rbind(journal, new.entry)
    }

  utils::write.csv(journal, "man/BenchJournal/journal.csv", row.names = FALSE)
  }
  cat("Finished running benchmarks! \n")
}
