#' @title Create interactive boxplots of benchmark results from journal.
#' @description Uses \code{ggplot2} and \code{plotly} to create boxplots for
#' each script in \code{man/BenchJournal/scripts} by package version.
#' @param units The unit of time to use for the plot. Either 's', 'ms', 'us'
#'     (microseconds), or 'ns'.
#' @export
JournalBoxPlot <- function(units = 's'){
  pkg.version <- time <- NULL
  journal <- utils::read.csv('man/BenchJournal/journal.csv')
  scripts <- unique(as.character(journal$script))

  for (script in scripts){
    script.results <- subset(journal, script == script)

    if (units %in% c('s','ms','us','ns') == FALSE){
      stop ('Provided unit for time not an expected value')
    }

    if (units == 's') script.results$time <- script.results$time / 10^9
    if (units == 'ms') script.results$time <- script.results$time / 10^6
    if (units == 'us') script.results$time <- script.results$time / 10^3



    p <- ggplot2::ggplot(ggplot2::aes(x = pkg.version, y = time),
                         data = script.results) + ggplot2::geom_boxplot()
    p <- p + ggplot2::xlab('Package Version')
    p <- p + ggplot2::ylab(paste('Time (', units,')', sep = ""))
    p <- p + ggplot2::ggtitle(paste('Benchmark Results for ', script,
                                    ' (',GetPkgName(),')', sep = "") )
    p <- p + ggplot2::theme_bw()



    p <- plotly::ggplotly(p)
    return(p)

  }

}
