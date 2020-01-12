#' @title Create folders in /man required for BenchJournal
#' @description  Sets up a \code{BenchmarkJournal} subdirectory in the
#'     \code{/man} directory. Inside this subdirectory, a csv file is created to
#'     hold the benchmark results and two additional folders. One for holding
#'     scripts to be benchmarked, called \code{scripts}. and one to hold plots,
#'     helpfully called \code{plots}.The \code{BenchmarkJournal} subdirectory is
#'     also added to .Rbuildignore
#' @export
Init <- function(){

  if (dir.exists('man/BenchJournal')){
    stop("Folders for BenchJournal have already been created!")
  }

  dir.create('man/BenchJournal')
  dir.create('man/BenchJournal/scripts')
  dir.create('man/BenchJournal/plots')

  NewJournal()

  usethis::use_build_ignore('man/BenchJournal')
}

#' @title Create a new journal file
#' @description Creates a new csv file to journal benchmark results, overwriting
#' the previous results. The user is asked to confirm overwriting an existing
#' file unless ask != TRUE
#' @param ask Logical. If TRUE then the user is asked to confirm overwriting
#'  the journal csv file.
#' @export
NewJournal <- function(ask = TRUE){
  if (ask == TRUE & file.exists('man/BenchJournal/journal.csv')){
    input <- readline('Do you wish to overwrite the journal which already exists? ')
    input <-tolower(input)
    acceptable.ans <- c('y', 'yes')

    if (input %in% acceptable.ans == F){
      stop('Not overwriting the journal')
    }
  }

    journal <- data.frame(script = character(0), time = character(0),
                          pkg.version = character(0), r.version = character(0),
                          test.date = character(0), system.name = character(0))
    utils::write.csv(journal, "man/BenchJournal/journal.csv", row.names = F)
}




#' @title Create new entry of benchmark results in the journal.
#' @description Uses \code{microbenchmark} to benchmark the scripts in
#' man/BenchJournal/scripts and then adds the results to the journal file.
#' @param times The number of times to benchmark each script.
#' @export
NewEntry <- function(times = 10){
  scripts <- dir('man/BenchJournal/scripts')

  pkg.name <- GetPkgName()


  if (length(scripts) == 0){
    stop('No R scripts found in man/BenchJournal/scripts')
  }
  journal <- utils::read.csv('man/BenchJournal/journal.csv', row.names = NULL,
                             stringsAsFactors = FALSE)
  journal$pkg.version <- as.vector(journal$pkg.version)
  journal$test.date <- as.vector(journal$test.date)


  if (as.character(utils::packageVersion(GetPkgName())) %in% unique(journal[,3])){
    stop(paste('Benchmark results have already been recorded for this version of ',
               pkg.name, " (",utils::packageVersion(GetPkgName()),")",
               sep = "" ))
  }
  for (script in scripts){
    new.entry <- CreateNewEntry(script, times)
    updated.journal<- rbind(journal, new.entry)
  }

  utils::write.csv(updated.journal, 'man/BenchJournal/journal.csv',
                   row.names = F)
}






