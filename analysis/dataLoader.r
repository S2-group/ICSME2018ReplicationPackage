library(extrafont)
library(dplyr)
library(tibble)
loadfonts()

apps <- read.csv(file="../data/apps.csv",head=TRUE,sep=",")
snapshots <- read.csv(file="../data/snapshots.csv",head=TRUE,sep=",")
commits <- read.csv(file="../data/commits.csv",head=TRUE,sep=",")



