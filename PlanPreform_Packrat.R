# Guide d'utilisation pour PACKRAT
# https://bioinfo-fr.net/packrat-ou-comment-gerer-ses-packages-r-par-projet

setwd("D:/T19QHL/Mes Documents/Planpreform/")
packrat::init(getwd())
packrat::on()

# Installation de packages dans le projet packrat

install.packages("shinythemes", dependencies = TRUE)
install.packages("shiny", dependencies = TRUE)
install.packages("readODS", dependencies = TRUE)
install.packages("plyr", dependencies = TRUE)
install.packages("dplyr", dependencies = TRUE)
install.packages("tidyr", dependencies = TRUE)
install.packages("stringr", dependencies = TRUE)
install.packages("xlsx", dependencies = TRUE)
install.packages("rChoiceDialogs", dependencies = TRUE)
install.packages("rmarkdown", dependencies = TRUE)
install.packages("DT", dependencies = TRUE)


# Afficher version des packages
packrat::snapshot()

# 
packrat::status()

#  Pour transrter le projet ... Création d'un ZIP
packrat::bundle()
