library(samplingbook)

# given the ID of a snapshot, get all the commits belonging to the same app of the snapshot and within its time window
getCommits <- function(snapshotId) {
  snap <- snapshots[which(snapshots$ID == snapshotId),]
  appName <- snap$shortName
  start <- snap$startTimestamp
  end <- snap$endTimestamp
  result <- commits[which((commits$shortName == appName) & (as.numeric(commits$commit_date) >= start) & (as.numeric(commits$commit_date) < end)),]
  result$snapshotId <- snapshotId
  return(result)
}

# here we populate a series of global variables (one for each type of maintainability issue) with commits belonging to outliers
aggregateCommits <- function() {
  print("starting commits.outliers.up.mt_density")
  commits.up.mt_density <<- c()
  for(i in 1:length(commits.outliers.up.mt_density)) {
    commits.up.mt_density <<- rbind(commits.up.mt_density, commits.outliers.up.mt_density[[i]])
  }
  print("starting commits.outliers.up.us_density")
  commits.up.us_density <<- c()
  for(i in 1:length(commits.outliers.up.us_density)) {
    commits.up.us_density <<- rbind(commits.up.us_density, commits.outliers.up.us_density[[i]])
  }
  print("starting commits.outliers.up.uc_density")
  commits.up.uc_density <<- c()
  for(i in 1:length(commits.outliers.up.uc_density)) {
    commits.up.uc_density <<- rbind(commits.up.uc_density, commits.outliers.up.uc_density[[i]])
  }
  print("starting commits.outliers.up.ui_density")
  commits.up.ui_density <<- c()
  for(i in 1:length(commits.outliers.up.ui_density)) {
    commits.up.ui_density <<- rbind(commits.up.ui_density, commits.outliers.up.ui_density[[i]])
  }
  print("starting commits.outliers.up.mc_density")
  commits.up.mc_density <<- c()
  for(i in 1:length(commits.outliers.up.mc_density)) {
    commits.up.mc_density <<- rbind(commits.up.mc_density, commits.outliers.up.mc_density[[i]])
  }
  print("starting commits.outliers.up.dp_density")
  commits.up.dp_density <<- c()
  for(i in 1:length(commits.outliers.up.dp_density)) {
    commits.up.dp_density <<- rbind(commits.up.dp_density, commits.outliers.up.dp_density[[i]])
  }
  
}

###########################################
# Getting commits for ALL outlier snapshots
###########################################

filteredSnapshots <- snapshots[which(snapshots[["outliers.up.mt_density"]] == 1),]
commits.outliers.up.mt_density <- lapply(filteredSnapshots$ID, function(x) getCommits(x))
filteredSnapshots <- snapshots[which(snapshots[["outliers.up.us_density"]] == 1),]
commits.outliers.up.us_density <- lapply(filteredSnapshots$ID, function(x) getCommits(x))
filteredSnapshots <- snapshots[which(snapshots[["outliers.up.uc_density"]] == 1),]
commits.outliers.up.uc_density <- lapply(filteredSnapshots$ID, function(x) getCommits(x))
filteredSnapshots <- snapshots[which(snapshots[["outliers.up.ui_density"]] == 1),]
commits.outliers.up.ui_density <- lapply(filteredSnapshots$ID, function(x) getCommits(x))
filteredSnapshots <- snapshots[which(snapshots[["outliers.up.mc_density"]] == 1),]
commits.outliers.up.mc_density <- lapply(filteredSnapshots$ID, function(x) getCommits(x))
filteredSnapshots <- snapshots[which(snapshots[["outliers.up.dp_density"]] == 1),]
commits.outliers.up.dp_density <- lapply(filteredSnapshots$ID, function(x) getCommits(x))

aggregateCommits()

# here we remove all NAs from the collected commits
commits.up.mt_density <- na.omit(commits.up.mt_density, cols=c("shortName"))
commits.up.us_density <- na.omit(commits.up.us_density, cols=c("shortName"))
commits.up.uc_density <- na.omit(commits.up.uc_density, cols=c("shortName"))
commits.up.ui_density <- na.omit(commits.up.ui_density, cols=c("shortName"))
commits.up.mc_density <- na.omit(commits.up.mc_density, cols=c("shortName"))
commits.up.dp_density <- na.omit(commits.up.dp_density, cols=c("shortName"))

# here we select a statistically significant sample of each set of commits pertaining to the set of outliers of each maintainability issue
sample.commits.up.mt_density <- sample_n(commits.up.mt_density, sample.size.prop(e = 0.05, P = 0.5, N = nrow(commits.up.mt_density), level = 0.95)$n)
sample.commits.up.us_density <- sample_n(commits.up.us_density, sample.size.prop(e = 0.05, P = 0.5, N = nrow(commits.up.us_density), level = 0.95)$n)
sample.commits.up.uc_density <- sample_n(commits.up.uc_density, sample.size.prop(e = 0.05, P = 0.5, N = nrow(commits.up.uc_density), level = 0.95)$n)
sample.commits.up.ui_density <- sample_n(commits.up.ui_density, sample.size.prop(e = 0.05, P = 0.5, N = nrow(commits.up.ui_density), level = 0.95)$n)
sample.commits.up.mc_density <- sample_n(commits.up.mc_density, sample.size.prop(e = 0.05, P = 0.5, N = nrow(commits.up.mc_density), level = 0.95)$n)
sample.commits.up.dp_density <- sample_n(commits.up.dp_density, sample.size.prop(e = 0.05, P = 0.5, N = nrow(commits.up.dp_density), level = 0.95)$n)

# It contains all commits belonging to all maintainability hotspots
TOTAL <- rbind(sample.commits.up.mt_density,
               sample.commits.up.us_density,
               sample.commits.up.uc_density,
               sample.commits.up.ui_density,
               sample.commits.up.mc_density,
               sample.commits.up.dp_density)

# This file will be used for the manual classification of the commits for identifying the developers' activities during outliers
write.csv(unique(TOTAL, by=ID), file="./results/sample.commits.up.TOTAL.csv", row.names = FALSE)

# we save also a file for each type of maintainability issue
write.csv(sample.commits.up.mt_density, file="./results/sample.commits.up.mt_density.csv", row.names = FALSE)
write.csv(sample.commits.up.us_density, file="./results/sample.commits.up.us_density.csv", row.names = FALSE)
write.csv(sample.commits.up.uc_density, file="./results/sample.commits.up.uc_density.csv", row.names = FALSE)
write.csv(sample.commits.up.ui_density, file="./results/sample.commits.up.ui_density.csv", row.names = FALSE)
write.csv(sample.commits.up.mc_density, file="./results/sample.commits.up.mc_density.csv", row.names = FALSE)
write.csv(sample.commits.up.dp_density, file="./results/sample.commits.up.dp_density.csv", row.names = FALSE)


