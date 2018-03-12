rm(list=ls())


bibliotheque <- "D:/T19QHL/Mes Documents/Appli R/Planpreform/packrat/lib/x86_64-w64-mingw32/3.4.2"

.libPaths(bibliotheque)
library(htmltools, lib.loc = bibliotheque, warn.conflicts = FALSE, quietly = TRUE, verbose = FALSE)
library(DT, lib.loc = bibliotheque, warn.conflicts = FALSE, quietly = TRUE, verbose = FALSE)
library(shiny, lib.loc = bibliotheque, warn.conflicts = FALSE, quietly = TRUE, verbose = FALSE)


runApp("D:/T19QHL/Mes Documents/Appli R/Planpreform/Pgm/", launch.browser = TRUE)

