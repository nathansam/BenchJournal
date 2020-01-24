#' @title Create folders in /man required for BenchJournal
#' @description  Sets up a \code{BenchmarkJournal} subdirectory in the
#'     \code{/man} directory. Inside this subdirectory, a csv file is created to
#'     hold the benchmark results and two additional folders. One for holding
#'     scripts to be benchmarked, called \code{scripts}. and one to hold plots,
#'     helpfully called \code{plots}.The \code{BenchmarkJournal} subdirectory is
#'     also added to .Rbuildignore
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

  use.hook <- readline(prompt = "Update BenchJournal with every git push? Y/n ")

  if (tolower(use.hook) %in% c("y", "yes")) {

    usethis::use_git_hook("pre-push",
    "#!/bin/sh
    Rscript -e 'BenchJournal::NewEntry()'
    git add man/BenchJournal/journal.csv
    git commit -m 'Update BenchJournal file'")

    cat("Updating with every git push \n")
  } else{
    cat("Not updating with every git push.\n")
    cat("Manually run NewEntry() to update the journal\n")
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
    journal <- data.frame(script = character(0), time = character(0),
                          pkg.version = character(0), r.version = character(0),
                          test.date = character(0), system.name = character(0))
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
#' @export
NewEntry <- function(times = 10, warmup = 2) {
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
    cat(paste("Benchmark results have already been recorded for this version of ",
               pkg.name, " (", utils::packageVersion(GetPkgName()), ")\n",
               sep = ""))
  } else{
    for (script in scripts) {
      new.entry <- CreateNewEntry(script, times, warmup = warmup)
      journal <- rbind(journal, new.entry)
    }

  utils::write.csv(journal, "man/BenchJournal/journal.csv",
                   row.names = F)
  }
}
