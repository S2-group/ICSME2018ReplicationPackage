library(extrafont)
library(dplyr)
library(tibble)
library(lubridate)
library(anytime)
library(forecast)
library(tseries)
library(stats)
library(GeneCycle)
loadfonts()

# given a name of maintainability issue, we add a column containing a boolean about whether it is stationary or not
checkStationarity <- function(violationName) {
  sigma <- 0.05 /6 # Sigma adjusted via the Bonferroni correction
  # here we perform the Augmented Dickey-Fuller test of stationarity on the time series built on the fly
  ts.violation <- unlist(lapply(apps$shortName, function(x) 
    as.numeric(unlist(adf.test(ts(snapshots[which(snapshots$shortName == x),][violationName], 
                                  frequency=4,
                                  start=anytime(apps[which(apps$shortName == x),]$StartTimestamp)
                                  )))["p.value"])))
  
  # it is stationary if the p-value of the ADF test is <= significance level, non-stationary otherwise
  stationary <- which(unlist(lapply(ts.violation, function(x) x <= sigma)))
  nonStationary <- which(unlist(lapply(ts.violation, function(x) x > sigma)))
  
  print(paste("Stationary:", length(stationary), "-"))
  print(paste("Non-stationary:", length(nonStationary)))
  print(paste("Total:", length(stationary) + length(nonStationary)))
  print(paste("NAs:", length(which(is.na(ts.violation)))))
  
  # we assign the specific Boolean values to each row of the dataframe
  ts.violation[nonStationary] <- F
  ts.violation[stationary] <- T
  ts.violation[is.na(ts.violation)] <- NA
  
  return(ts.violation)
}

# for each maintainability issue type, we add a column containing a boolean about whether it is stationary or not
apps$stationary.mt_density <- checkStationarity("mt_density")
apps$stationary.us_density <- checkStationarity("us_density")
apps$stationary.uc_density <- checkStationarity("uc_density")
apps$stationary.ui_density <- checkStationarity("ui_density")
apps$stationary.mc_density <- checkStationarity("mc_density")
apps$stationary.dp_density <- checkStationarity("dp_density")

# write the apps CSV file
write.csv(apps, file="../data/apps.csv", row.names = FALSE)



