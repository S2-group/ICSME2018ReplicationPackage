library(extrafont)
library(dplyr)
library(tibble)
library(lubridate)
library(anytime)
library(forecast)
library(tseries)
library(stats)
library(GeneCycle)
library(tsoutliers)
library (astsa)
loadfonts()

# this function builds the periodogram of the maintainability issue called "violationName" of app "appName" and returns (1 / its dominant frequency)
getPeriod <- function(appName, violationName) {
  appViolation <- snapshots[which(snapshots$shortName == appName),][violationName]
  startApp <- anytime(apps[which(apps$shortName == appName),]$StartTimestamp)
  endApp <- anytime(apps[which(apps$shortName == appName),]$EndTimestamp)
  app.ts <- ts(appViolation, frequency=4, start=startApp)
  periodogram <- TSA::periodogram(app.ts, plot=F)
  return(1/ periodogram$freq[which.max(periodogram$spec)])
}

# given the maintainability issue called "violationName" of app "appName", we build its STL model
buildTsModel <- function(appName, violationName) {
  app <- apps[which(apps$shortName == appName),]
  appViolation <- snapshots[which(snapshots$shortName == appName),][[violationName]]
  startApp <- anytime(app$StartTimestamp)
  endApp <- anytime(apps[which(apps$shortName == appName),]$EndTimestamp)
  # the period column should have been already populated now
  period <- as.numeric(app[paste("periods.", violationName,sep="")])
  if(as.numeric(app$nSnapshots) <= (period * 2)) {
    period <- (as.numeric(app$nSnapshots) / 2) - 1
  }
  appTs <- ts(as.vector(appViolation), frequency=period, start=startApp)
  modelstl <- stl(appTs, s.window = "periodic")
  return(modelstl)
}

# given the maintainability issue called "violationName" of app "appName", we build its time series
buildTs <- function(appName, violationName) {
  app <- apps[which(apps$shortName == appName),]
  appViolation <- snapshots[which(snapshots$shortName == appName),][[violationName]]
  startApp <- anytime(app$StartTimestamp)
  endApp <- anytime(apps[which(apps$shortName == appName),]$EndTimestamp)
  # the period column should have been already populated now
  period <- as.numeric(app[paste("periods.", violationName,sep="")])
  if(as.numeric(app$nSnapshots) <= (period * 2)) {
    period <- (as.numeric(app$nSnapshots) / 2) - 1
  }
  appTs <- ts(as.vector(appViolation), frequency=period, start=startApp)
  return(appTs)
}

# generic plotting function.
# Parameters: name of the file where the plots will be saved, name of the maintainability issue, the prefix of the name of the column to be plotted
savePlots <- function(fileName, violationName, attributePrefix) {
  pdf(paste(fileName, "___", violationName, ".pdf", sep = ""))
  for(i in 1:nrow(apps)) {
    print(paste("plotting", apps[i,]$shortName, "-", i))
    toPrint <- apps[i,][[paste(attributePrefix, violationName, sep = "")]]
    plotTitle <- paste(apps[i,]$shortName, "-", apps[i,]$nSnapshots, "weeks")
    if(!is.na(toPrint)) {
      plot(toPrint[[1]], main = plotTitle)
    }
  }
  dev.off()
}

# It plots all snapshots of all apps into a single pdf file. It is useful for visual inspection of the results of the outliers identification strategy
# Parameters: the file to be saved, the name of the maintainability issue to be considered, boolean for showing outliers differently or not, direction of the outliers ("up" or "down")
plotAppsSnapshots <- function(fileName, violationName, toPdf, showOutliers, direction) {
  if(toPdf) {
    pdf(paste(fileName, "___", violationName, ".pdf", sep = ""))
  }
  # here we iterate over all apps and plot
  for(i in 1:nrow(apps)) {
    print(paste("plotting", apps[i,]$shortName, "-", i))
    plotSingleAppSnapshot(apps[i,]$shortName, violationName, showOutliers, direction)
  }
  if(toPdf) {
    dev.off()
  }
}

# given a series of snapshots and a direction, we extract its outliers (see paper for the definition of the outliers)
# values of the direction parameter: "up" and "down"
identifyOutliers <- function(snaps, direction) {
  sd <- sd(snaps)
  result <- rep(0, length(snaps))
  for(i in 2:length(snaps)) {
    if(direction == "up") {
      if((snaps[i] - snaps[i-1]) > sd) {
        result[i] <- 1  
      }
    } else {
      if((snaps[i-1] - snaps[i]) > sd) {
        result[i] <- 1  
      }
    }
  }
  return(result)
}

# Used for quickly inspecting identified outliers.
# It creates a plot related to the maintainability issue called "violationName" of app "appName", a direction for outliers ("up" or "down"), and a boolean for telling if we want to distinguish outliers from standard snapshots
plotSingleAppSnapshot <- function(appName, violationName, showOutliers, direction) {
  snaps <- snapshots[which(snapshots$shortName == appName),]
  if(showOutliers) {
    # outliers are shown as red dots, standard snapshots as black dots
    outlierColor <- ifelse(identifyOutliers(snaps[[violationName]], direction) > 0,'red','black')
  } else {
    outlierColor <- "black"
  }
  plot(snaps[[violationName]], main = appName, ylim=c(0,max(snaps[[violationName]]) + 5), col = outlierColor, pch = 20)
  lines(snaps[[violationName]])
  text(x = c(1:nrow(snaps)), y = snaps[[violationName]] + 1.5,  label = snaps$ID, cex=0.6)
  grid()
  
  # we show also the linear regression in the plot
  reg <- lm(snaps[[violationName]] ~ c(1:nrow(snaps)))
  coeff <- coefficients(reg)
  eq  <- paste0("y = ", round(coeff[2],1), "*x ", round(coeff[1],1))
  abline(reg, col="red")
  
  # we show also the mean and median in the plot
  abline(h = mean(snaps[[violationName]]), col="blue")
  abline(h = median(snaps[[violationName]]), col="green")
  
}

# given the maintainability issue called "violationName" of app "appName", and a direction for outliers ("up" or "down"), identify all the outliers
identifyAllAppsSnapshots <- function(appName, violationName, direction) {
    print(paste("identifying snapshots for", appName, "- violation:", violationName))
    snaps <- snapshots[which(snapshots$shortName == appName),]
    outliers <- identifyOutliers(snaps[[violationName]], direction)
    return(outliers)
}

# We identify the dominant period for each app and for each maintainability issue type
apps$periods.mt_density <- unlist(lapply(apps$shortName, function(x) getPeriod(x, "mt_density")))
apps$periods.us_density <- unlist(lapply(apps$shortName, function(x) getPeriod(x, "us_density")))
apps$periods.uc_density <- unlist(lapply(apps$shortName, function(x) getPeriod(x, "uc_density")))
apps$periods.ui_density <- unlist(lapply(apps$shortName, function(x) getPeriod(x, "ui_density")))
apps$periods.mc_density <- unlist(lapply(apps$shortName, function(x) getPeriod(x, "mc_density")))
apps$periods.dp_density <- unlist(lapply(apps$shortName, function(x) getPeriod(x, "dp_density")))

# We build the STL model for each app and for each maintainability issue type
apps$modelstl.mt_density <- lapply(apps$shortName, function(x) buildTsModel(x, "mt_density"))
apps$modelstl.us_density <- lapply(apps$shortName, function(x) buildTsModel(x, "us_density"))
apps$modelstl.uc_density <- lapply(apps$shortName, function(x) buildTsModel(x, "uc_density"))
apps$modelstl.ui_density <- lapply(apps$shortName, function(x) buildTsModel(x, "ui_density"))
apps$modelstl.mc_density <- lapply(apps$shortName, function(x) buildTsModel(x, "mc_density"))
apps$modelstl.dp_density <- lapply(apps$shortName, function(x) buildTsModel(x, "dp_density"))

# We build the time series of each app and for each maintainability issue type
apps$ts.mt_density <- lapply(apps$shortName, function(x) buildTs(x, "mt_density"))
apps$ts.us_density <- lapply(apps$shortName, function(x) buildTs(x, "us_density"))
apps$ts.uc_density <- lapply(apps$shortName, function(x) buildTs(x, "uc_density"))
apps$ts.ui_density <- lapply(apps$shortName, function(x) buildTs(x, "ui_density"))
apps$ts.mc_density <- lapply(apps$shortName, function(x) buildTs(x, "mc_density"))
apps$ts.dp_density <- lapply(apps$shortName, function(x) buildTs(x, "dp_density"))

# here we save all the decompositions of the time series for each app and for each maintainability issue type. They will be used for our qualitative analysis
savePlots("tsDecompositions", "mt_density", "modelstl.")
savePlots("tsDecompositions", "us_density", "modelstl.")
savePlots("tsDecompositions", "uc_density", "modelstl.")
savePlots("tsDecompositions", "ui_density", "modelstl.")
savePlots("tsDecompositions", "mc_density", "modelstl.")
savePlots("tsDecompositions", "dp_density", "modelstl.")

# we identify the outliers and add a dedicated column for each maintainability issue in the snapshots global dataframe
snapshots$outliers.up.mt_density <- unlist(lapply(apps$shortName, function(x) identifyAllAppsSnapshots(x, "mt_density", "up")))
snapshots$outliers.up.us_density <- unlist(lapply(apps$shortName, function(x) identifyAllAppsSnapshots(x, "us_density", "up")))
snapshots$outliers.up.uc_density <- unlist(lapply(apps$shortName, function(x) identifyAllAppsSnapshots(x, "ui_density", "up")))
snapshots$outliers.up.ui_density <- unlist(lapply(apps$shortName, function(x) identifyAllAppsSnapshots(x, "ui_density", "up")))
snapshots$outliers.up.mc_density <- unlist(lapply(apps$shortName, function(x) identifyAllAppsSnapshots(x, "mc_density", "up")))
snapshots$outliers.up.dp_density <- unlist(lapply(apps$shortName, function(x) identifyAllAppsSnapshots(x, "dp_density", "up")))
