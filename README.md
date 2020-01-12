
<!-- README.md is generated from README.Rmd. Please edit that file -->

# BenchJournal

<!-- badges: start -->

<!-- badges: end -->

BenchJournal is a tool to keep track of package benchmarks as the
package is developed.

## Installation

You can install the development version of BenchJournal with:

``` r
# install.packages("devtools")
devtools::install_github("nathansam/BenchJournal")
```

## Using BenchJournal

BenchJournal can be set up using a simple function which will create
folders/files need to journal your package’s progress in
`/man/BenchJournal/` and will add these folders/ files to your
`.Rbuildignore`.

``` r
BenchJournal::Init()
```

Inside `/man/BenchJournal/`, you will now find a folder `scripts`. Save
any R scripts to this directory which you wish to benchmark (I.E. a
script which uses the functions in your package which you are intending
to improve the performance of).

Run `NewEntry` to add an entry to your journal file (located at
`/man/BenchJournal/`).

``` r
BenchJournal::NewEntry()
```

After making changes to your package, update the version of your
package, and re-run `NewEntry` to add to your journal.

An interactive boxplot of your benchmark results using ggplot and plotly
can then be generated by using:

``` r
BenchJournal::JournalBoxPlot()
```

![Boxplot of benchmark results](man/figures/BASSLINE-ex.jpg)
