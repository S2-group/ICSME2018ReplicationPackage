library(extrafont)
library(ggplot2)
library(questionr)
library(dplyr)
library(plyr)
library(tibble)
library(reshape2)
library(RColorBrewer)
library(vioplot)

loadfonts()
setwd(".")

data <- read.csv(file="./labelledData/labelled_commits.csv", head=TRUE, sep=",", stringsAsFactors=TRUE)
dataMS <- read.csv(file="./labelledData/labelled_commits_MobileSoft_2018.csv", head=TRUE, sep=",", stringsAsFactors=TRUE)

##################### Data import and checks

# Renaming the Debug top-level category into "Testing & debugging"
levels(data$level1_1) <- gsub("Debug","Testing & debugging", levels(data$level1_1))
levels(data$level1_2) <- gsub("Debug","Testing & debugging", levels(data$level1_2))
levels(data$level1_3) <- gsub("Debug","Testing & debugging", levels(data$level1_3))

levels(dataMS$level1_1) <- gsub("Debug","Testing & debugging", levels(dataMS$level1_1))
levels(dataMS$level1_2) <- gsub("Debug","Testing & debugging", levels(dataMS$level1_2))
levels(dataMS$level1_3) <- gsub("Debug","Testing & debugging", levels(dataMS$level1_3))

# check all rows for which there is no main categorization
emptyMainTag <- data[which(data$level1_1 == ""),]
print(emptyMainTag$commitMessage)

emptyMainTag2 <- dataMS[which(dataMS$level1_1 == ""),]
print(emptyMainTag2$commitMessage)

# check all rows for which there is no app category
emptyCategory <- data[which(data$appCategory == ""),]
print(unique(emptyCategory$repo))

emptyCategory2 <- dataMS[which(dataMS$appCategory == ""),]
print(unique(emptyCategory2$repo))

analyzePlotData <- function(data, dataMS) {
  ##################### Data reshaping
  
  # Let's reshape the data from wide to long format
  dataLong <- reshape(data, varying=c("level2_1", "level2_2", "level2_3", "level1_1", "level1_2", "level1_3"), direction="long", idvar="commit_sha", sep="_")
  dataLongMS <- reshape(dataMS, varying=c("level2_1", "level2_2", "level2_3", "level1_1", "level1_2", "level1_3"), direction="long", idvar="commit_sha", sep="_")
  
  # change the names of the added columns so to have the "_" separator
  names(dataLong)[10] <- "level_1"
  names(dataLong)[9] <- "level_2"
  
  names(dataLongMS)[18] <- "level_1"
  names(dataLongMS)[17] <- "level_2"
  
  # Remove all items for which there is no level1 or level2 defined, it is a consequence of the reshape instruction
  dataLong <- dataLong[which(dataLong$level_1 != "" | dataLong$level_2 != ""),]
  dataLongMS <- dataLongMS[which(dataLongMS$level_1 != "" | dataLongMS$level_2 != ""),]
  
  dataLong <<- dataLong

  # Remove all items with main category = Turtle
  dataLong <- dataLong[which(dataLong$level_1 != "Turtle"),]
  dataLongMS <- dataLongMS[which(dataLongMS$level_1 != "Turtle"),]
  
  # Remove the "time" column
  dataLong <- subset(dataLong, select = -c(time) )
  dataLongMS <- subset(dataLongMS, select = -c(time) )

  ##################### It's plotting time!
  
  # we combine the level_1 and level_2 variables
  dataLong <- reshape(dataLong, varying=c("level_1", "level_2"), direction="long", idvar="commit_sha", sep="_", new.row.names=c(1:10000000))
  dataLong <- dataLong[which(dataLong$level != ""),]
  
  dataLongMS <- reshape(dataLongMS, varying=c("level_1", "level_2"), direction="long", idvar="commit_sha", sep="_", new.row.names=c(1:10000000))
  dataLongMS <- dataLongMS[which(dataLongMS$level != ""),]
  
  # we rename all the levels of the "level" variable so that they appear in the plot as in the paper.
  levels(dataLong$level) <- gsub("Enhancement", "A - App enhancement", levels(dataLong$level))
  levels(dataLong$level) <- gsub("NewFeature", "A.1 - New feature", levels(dataLong$level))
  levels(dataLong$level) <- gsub("Changes", "A.2 - Feature changes", levels(dataLong$level))
  levels(dataLong$level) <- gsub("Usability", "A.3 - Usability", levels(dataLong$level))
  levels(dataLong$level) <- gsub("Language", "A.4 - Language", levels(dataLong$level))
  levels(dataLong$level) <- gsub("Lifecycle", "A.5 - Android lifecycle", levels(dataLong$level))
  levels(dataLong$level) <- gsub("Monetization", "A.6 - Monetization", levels(dataLong$level))
  levels(dataLong$level) <- gsub("Utility", "A.7 - Utility", levels(dataLong$level))
  levels(dataLong$level) <- gsub("Bug Fix", "B - Bug fixing", levels(dataLong$level))
  levels(dataLong$level) <- gsub("App Specific", "B.1 - App specific", levels(dataLong$level))
  levels(dataLong$level) <- gsub("Performance", "B.2 - Performance", levels(dataLong$level))
  levels(dataLong$level) <- gsub("Security", "B.3 - Security", levels(dataLong$level))
  levels(dataLong$level) <- gsub("Crash", "B.4 - Crash", levels(dataLong$level))
  levels(dataLong$level) <- gsub("Energy", "B.5 - Energy", levels(dataLong$level))
  levels(dataLong$level) <- gsub("Project management", "C - Project management", levels(dataLong$level))
  levels(dataLong$level) <- gsub("MetaGithub", "C.1 - GitHub-related", levels(dataLong$level))
  levels(dataLong$level) <- gsub("Release", "C.2 - Release management", levels(dataLong$level))
  levels(dataLong$level) <- gsub("TODO", "C.3 - Todo item", levels(dataLong$level))
  levels(dataLong$level) <- gsub("Documentation", "C.4 - Documentation", levels(dataLong$level))
  levels(dataLong$level) <- gsub("Build", "C.5 - Build", levels(dataLong$level))
  levels(dataLong$level) <- gsub("Manifest", "C.6 - Manifest", levels(dataLong$level))
  levels(dataLong$level) <- gsub("IDE", "C.7 - IDE", levels(dataLong$level))
  levels(dataLong$level) <- gsub("Code Re-Organization", "D - Code re-organization", levels(dataLong$level))
  levels(dataLong$level) <- gsub("Refactoring", "D.1 - Refactoring", levels(dataLong$level))
  levels(dataLong$level) <- gsub("Cleanup", "D.2 - Code cleanup", levels(dataLong$level))
  levels(dataLong$level) <- gsub("FeatureRemove", "D.3 - Feature removal", levels(dataLong$level))
  levels(dataLong$level) <- gsub("Resize", "D.4 - Reduce app size", levels(dataLong$level))
  levels(dataLong$level) <- gsub("CodeDead", "D.5 - Dead code elimination", levels(dataLong$level))
  levels(dataLong$level) <- gsub("^UI", "E - User experience improvement", levels(dataLong$level))
  levels(dataLong$level) <- gsub("GUI", "E.1 - GUI", levels(dataLong$level))
  levels(dataLong$level) <- gsub("Strings", "E.2 - Strings", levels(dataLong$level))
  levels(dataLong$level) <- gsub("Icon", "E.3 - Images", levels(dataLong$level))
  levels(dataLong$level) <- gsub("Gesture", "E.4 - Gesture", levels(dataLong$level))
  levels(dataLong$level) <- gsub("Orientation", "E.5 - Orientation", levels(dataLong$level))
  levels(dataLong$level) <- gsub("Dialog", "E.6 - Dialog", levels(dataLong$level))
  levels(dataLong$level) <- gsub("Menu", "E.7 - Menu", levels(dataLong$level))
  levels(dataLong$level) <- gsub("Storage", "F - Storage management", levels(dataLong$level))
  levels(dataLong$level) <- gsub("Settings", "F.1 - Settings", levels(dataLong$level))
  levels(dataLong$level) <- gsub("DB", "F.2 - Local database", levels(dataLong$level))
  levels(dataLong$level) <- gsub("FileSystem", "F.3 - File system", levels(dataLong$level))
  levels(dataLong$level) <- gsub("Sensing & communication", "G - Sensing  & communication", levels(dataLong$level))
  levels(dataLong$level) <- gsub("Networking", "G.1 - Network", levels(dataLong$level))
  levels(dataLong$level) <- gsub("Audio", "G.2 - Audio", levels(dataLong$level))
  levels(dataLong$level) <- gsub("^Image", "G.3 - Image", levels(dataLong$level))
  levels(dataLong$level) <- gsub("Sensors", "G.4 - Sensor", levels(dataLong$level))
  levels(dataLong$level) <- gsub("Camera", "G.5 - Camera", levels(dataLong$level))
  levels(dataLong$level) <- gsub("Messaging", "G.6 - Messaging", levels(dataLong$level))
  levels(dataLong$level) <- gsub("Call", "G.7 - Call", levels(dataLong$level))
  levels(dataLong$level) <- gsub("Mic", "G.8 - Microphone", levels(dataLong$level))
  levels(dataLong$level) <- gsub("API Management", "H - API management", levels(dataLong$level))
  levels(dataLong$level) <- gsub("Library", "H.1 - Library", levels(dataLong$level))
  levels(dataLong$level) <- gsub("API_Android", "H.2 - Android API", levels(dataLong$level))
  levels(dataLong$level) <- gsub("API_REST", "H.3 - REST API", levels(dataLong$level))
  levels(dataLong$level) <- gsub("Deprecation", "H.4 - Deprecation", levels(dataLong$level))
  levels(dataLong$level) <- gsub("^Testing & debugging", "I - Testing & debugging", levels(dataLong$level))
  levels(dataLong$level) <- gsub("^Test", "I.1 - Testing", levels(dataLong$level))
  levels(dataLong$level) <- gsub("Logging", "I.2 - Logging", levels(dataLong$level))
  levels(dataLong$level) <- gsub("Debug", "I.3 - Debugging", levels(dataLong$level))
  
  # we rename all the levels of the "level" variable so that they appear in the plot as in the paper.
  levels(dataLongMS$level) <- gsub("Enhancement", "A - App enhancement", levels(dataLongMS$level))
  levels(dataLongMS$level) <- gsub("NewFeature", "A.1 - New feature", levels(dataLongMS$level))
  levels(dataLongMS$level) <- gsub("Changes", "A.2 - Feature changes", levels(dataLongMS$level))
  levels(dataLongMS$level) <- gsub("Usability", "A.3 - Usability", levels(dataLongMS$level))
  levels(dataLongMS$level) <- gsub("Language", "A.4 - Language", levels(dataLongMS$level))
  levels(dataLongMS$level) <- gsub("Lifecycle", "A.5 - Android lifecycle", levels(dataLongMS$level))
  levels(dataLongMS$level) <- gsub("Monetization", "A.6 - Monetization", levels(dataLongMS$level))
  levels(dataLongMS$level) <- gsub("Utility", "A.7 - Utility", levels(dataLongMS$level))
  levels(dataLongMS$level) <- gsub("Bug Fix", "B - Bug fixing", levels(dataLongMS$level))
  levels(dataLongMS$level) <- gsub("App Specific", "B.1 - App specific", levels(dataLongMS$level))
  levels(dataLongMS$level) <- gsub("Performance", "B.2 - Performance", levels(dataLongMS$level))
  levels(dataLongMS$level) <- gsub("Security", "B.3 - Security", levels(dataLongMS$level))
  levels(dataLongMS$level) <- gsub("Crash", "B.4 - Crash", levels(dataLongMS$level))
  levels(dataLongMS$level) <- gsub("Energy", "B.5 - Energy", levels(dataLongMS$level))
  levels(dataLongMS$level) <- gsub("Project management", "C - Project management", levels(dataLongMS$level))
  levels(dataLongMS$level) <- gsub("MetaGithub", "C.1 - GitHub-related", levels(dataLongMS$level))
  levels(dataLongMS$level) <- gsub("Release", "C.2 - Release management", levels(dataLongMS$level))
  levels(dataLongMS$level) <- gsub("TODO", "C.3 - Todo item", levels(dataLongMS$level))
  levels(dataLongMS$level) <- gsub("Documentation", "C.4 - Documentation", levels(dataLongMS$level))
  levels(dataLongMS$level) <- gsub("Build", "C.5 - Build", levels(dataLongMS$level))
  levels(dataLongMS$level) <- gsub("Manifest", "C.6 - Manifest", levels(dataLongMS$level))
  levels(dataLongMS$level) <- gsub("IDE", "C.7 - IDE", levels(dataLongMS$level))
  levels(dataLongMS$level) <- gsub("Code Re-Organization", "D - Code re-organization", levels(dataLongMS$level))
  levels(dataLongMS$level) <- gsub("Refactoring", "D.1 - Refactoring", levels(dataLongMS$level))
  levels(dataLongMS$level) <- gsub("Cleanup", "D.2 - Code cleanup", levels(dataLongMS$level))
  levels(dataLongMS$level) <- gsub("FeatureRemove", "D.3 - Feature removal", levels(dataLongMS$level))
  levels(dataLongMS$level) <- gsub("Resize", "D.4 - Reduce app size", levels(dataLongMS$level))
  levels(dataLongMS$level) <- gsub("CodeDead", "D.5 - Dead code elimination", levels(dataLongMS$level))
  levels(dataLongMS$level) <- gsub("^UI", "E - User experience improvement", levels(dataLongMS$level))
  levels(dataLongMS$level) <- gsub("GUI", "E.1 - GUI", levels(dataLongMS$level))
  levels(dataLongMS$level) <- gsub("Strings", "E.2 - Strings", levels(dataLongMS$level))
  levels(dataLongMS$level) <- gsub("Icon", "E.3 - Images", levels(dataLongMS$level))
  levels(dataLongMS$level) <- gsub("Gesture", "E.4 - Gesture", levels(dataLongMS$level))
  levels(dataLongMS$level) <- gsub("Orientation", "E.5 - Orientation", levels(dataLongMS$level))
  levels(dataLongMS$level) <- gsub("Dialog", "E.6 - Dialog", levels(dataLongMS$level))
  levels(dataLongMS$level) <- gsub("Menu", "E.7 - Menu", levels(dataLongMS$level))
  levels(dataLongMS$level) <- gsub("Storage", "F - Storage management", levels(dataLongMS$level))
  levels(dataLongMS$level) <- gsub("Settings", "F.1 - Settings", levels(dataLongMS$level))
  levels(dataLongMS$level) <- gsub("DB", "F.2 - Local database", levels(dataLongMS$level))
  levels(dataLongMS$level) <- gsub("FileSystem", "F.3 - File system", levels(dataLongMS$level))
  levels(dataLongMS$level) <- gsub("Sensing & communication", "G - Sensing  & communication", levels(dataLongMS$level))
  levels(dataLongMS$level) <- gsub("Networking", "G.1 - Network", levels(dataLongMS$level))
  levels(dataLongMS$level) <- gsub("Audio", "G.2 - Audio", levels(dataLongMS$level))
  levels(dataLongMS$level) <- gsub("^Image", "G.3 - Image", levels(dataLongMS$level))
  levels(dataLongMS$level) <- gsub("Sensors", "G.4 - Sensor", levels(dataLongMS$level))
  levels(dataLongMS$level) <- gsub("Camera", "G.5 - Camera", levels(dataLongMS$level))
  levels(dataLongMS$level) <- gsub("Messaging", "G.6 - Messaging", levels(dataLongMS$level))
  levels(dataLongMS$level) <- gsub("Call", "G.7 - Call", levels(dataLongMS$level))
  levels(dataLongMS$level) <- gsub("Mic", "G.8 - Microphone", levels(dataLongMS$level))
  levels(dataLongMS$level) <- gsub("API Management", "H - API management", levels(dataLongMS$level))
  levels(dataLongMS$level) <- gsub("Library", "H.1 - Library", levels(dataLongMS$level))
  levels(dataLongMS$level) <- gsub("API_Android", "H.2 - Android API", levels(dataLongMS$level))
  levels(dataLongMS$level) <- gsub("API_REST", "H.3 - REST API", levels(dataLongMS$level))
  levels(dataLongMS$level) <- gsub("Deprecation", "H.4 - Deprecation", levels(dataLongMS$level))
  levels(dataLongMS$level) <- gsub("^Testing & debugging", "I - Testing & debugging", levels(dataLongMS$level))
  levels(dataLongMS$level) <- gsub("^Test", "I.1 - Testing", levels(dataLongMS$level))
  levels(dataLongMS$level) <- gsub("Logging", "I.2 - Logging", levels(dataLongMS$level))
  levels(dataLongMS$level) <- gsub("Debug", "I.3 - Debugging", levels(dataLongMS$level))
  
  # Let's order the factors alphabetically so that it will be easy to check the obtained results 
  dataLong$level <- factor(dataLong$level, levels = sort(as.character(levels(dataLong$level)), decreasing = TRUE))
  dataLongMS$level <- factor(dataLongMS$level, levels = sort(as.character(levels(dataLongMS$level)), decreasing = TRUE))
  
  # we store all the counts for each type of developer activity for both datasets (ICSME and MobileSoft)
  countsICSME <- plyr::count(dataLong$level)
  countsMS <- plyr::count(dataLongMS$level)
  
  # let's check them visually first
  print(countsICSME)
  print(countsMS)
  
  # x must be a character
  countsICSME$x <- as.character(countsICSME$x)
  
  # the following categories where empty in countsICSME, so we need to manually add them, so that they will be levels of the x factor
  countsICSME <- rbind(countsICSME, c("x"= "G.6 - Messaging", "freq"= 0))
  countsICSME <- rbind(countsICSME, c("x"= "G.7 - Call", "freq"= 0))
  countsICSME <- rbind(countsICSME, c("x"= "B.5 - Energy", "freq"= 0))
  countsICSME <- rbind(countsICSME, c("x"= "G.8 - Microphone", "freq"= 0))
  
  # x should be a factor column now
  countsICSME$x <- as.factor(countsICSME$x)
  
  # here we store the percentages
  countsICSME$percICSME <- (as.numeric(countsICSME$freq) / 2112) * 100
  countsMS$percMS <- (as.numeric(countsMS$freq) / 5000) * 100
  
  # we rename the columns we initialized before
  names(countsICSME)[2] <- "freqICSME"
  names(countsMS)[2] <- "freqMS"
  
  # this is for debugging purposes, in the global variable "a" we put the join of the dataframes belonging to the 2 dataframes 
  a <<- inner_join(countsICSME, countsMS, by = c("x"))
  # in the diff column of "a" we put the differences between the ICSME dataset and the MobileSoft one
  a$diff <<- a$percICSME - a$percMS

  # we add dedicated columns for the Source of the data, it can be either "ICSME" or "MS" (it stands for MobileSoft)
  dataLong$Source <- "ICSME"
  dataLongMS$Source <- "MS"
  
  # we merge the two datasets into a single dataframe called dataTOTAL
  dataLongFINAL <- subset(dataLong, select = c(level, Source))
  dataLongMSFINAL <- subset(dataLongMS, select = c(level, Source))
  dataTOTAL <- rbind(dataLongFINAL, dataLongMSFINAL)

  # we clean the level column by removing unused levels
  dataTOTAL$level <- droplevels(dataTOTAL$level)
  # we build a table out of dataTOTAL, so that we can calculate its Chi Square value and Cramer's V
  tableTOTAL <- table(dataTOTAL$Source, dataTOTAL$level) 
  chisquare <- chisq.test(tableTOTAL, correct = T, simulate.p.value = F)
  cramer <- cramer.v(tableTOTAL)
  
  # we print and return the obtained Chi Square value and its Cramer's V
  result <- c("chisquare" = chisquare$p.value, "cramer" = cramer)
  print(result)
  return(result)
}

# here we will store all Chi Square values and Cramer's Vs
chisquare.pvalues <- c()
cramer <- c()

######### in the following blocks we comput the Chi Square values and Cramer's Vs for each type of maintainability issue

filteredSnapshots <- snapshots[which(snapshots[["outliers.up.mt_density"]] == 1),]
names(filteredSnapshots)[32] <- "snapshotId"
filteredSnapshots <- subset(filteredSnapshots, select = c(snapshotId) )
filteredData <- inner_join(filteredSnapshots, data, by=c("snapshotId", "snapshotId"))
filteredData <- data
result <- analyzePlotData(filteredData, dataMS)
chisquare.pvalues["MT"] <- result[1]
cramer["MT"] <- result[2]

filteredSnapshots <- snapshots[which(snapshots[["outliers.up.us_density"]] == 1),]
names(filteredSnapshots)[32] <- "snapshotId"
filteredSnapshots <- subset(filteredSnapshots, select = c(snapshotId) )
filteredData <- inner_join(filteredSnapshots, data, by=c("snapshotId", "snapshotId"))
result <- analyzePlotData(filteredData, dataMS)
chisquare.pvalues["US"] <- result[1]
cramer["US"] <- result[2]

filteredSnapshots <- snapshots[which(snapshots[["outliers.up.ui_density"]] == 1),]
names(filteredSnapshots)[32] <- "snapshotId"
filteredSnapshots <- subset(filteredSnapshots, select = c(snapshotId) )
filteredData <- inner_join(filteredSnapshots, data, by=c("snapshotId", "snapshotId"))
result <- analyzePlotData(filteredData, dataMS)
chisquare.pvalues["UI"] <- result[1]
cramer["UI"] <- result[2]

filteredSnapshots <- snapshots[which(snapshots[["outliers.up.mc_density"]] == 1),]
names(filteredSnapshots)[32] <- "snapshotId"
filteredSnapshots <- subset(filteredSnapshots, select = c(snapshotId) )
filteredData <- inner_join(filteredSnapshots, data, by=c("snapshotId", "snapshotId"))
result <- analyzePlotData(filteredData, dataMS)
chisquare.pvalues["MC"] <- result[1]
cramer["MC"] <- result[2]

filteredSnapshots <- snapshots[which(snapshots[["outliers.up.uc_density"]] == 1),]
names(filteredSnapshots)[32] <- "snapshotId"
filteredSnapshots <- subset(filteredSnapshots, select = c(snapshotId) )
filteredData <- inner_join(filteredSnapshots, data, by=c("snapshotId", "snapshotId"))
result <- analyzePlotData(filteredData, dataMS)
chisquare.pvalues["UC"] <- result[1]
cramer["UC"] <- result[2]

filteredSnapshots <- snapshots[which(snapshots[["outliers.up.dp_density"]] == 1),]
names(filteredSnapshots)[32] <- "snapshotId"
filteredSnapshots <- subset(filteredSnapshots, select = c(snapshotId) )
filteredData <- inner_join(filteredSnapshots, data, by=c("snapshotId", "snapshotId"))
result <- analyzePlotData(filteredData, dataMS)
chisquare.pvalues["DP"] <- result[1]
cramer["DP"] <- result[2]

filteredSnapshots <- snapshots
names(filteredSnapshots)[32] <- "snapshotId"
filteredSnapshots <- subset(filteredSnapshots, select = c(snapshotId) )
filteredData <- inner_join(filteredSnapshots, data, by=c("snapshotId", "snapshotId"))
result <- analyzePlotData(filteredData, dataMS)
chisquare.pvalues["ALL"] <- result[1]
cramer["ALL"] <- result[2]

# this function creates the large heatmap in which we visually correlate issue types and developer's activities
buildTiles <- function() {

  # Let's reshape the data from wide to long format
  dataLong <- reshape(data, varying=c("level2_1", "level2_2", "level2_3", "level1_1", "level1_2", "level1_3"), direction="long", idvar="commit_sha", sep="_")

  # change the names of the added columns so to have the "_" separator
  names(dataLong)[10] <- "level_1"
  names(dataLong)[9] <- "level_2"

  # Remove all items for which there is no level1 or level2 defined, it is a consequence of the reshape instruction
  dataLong <- dataLong[which(dataLong$level_1 != "" | dataLong$level_2 != ""),]

  # Remove all items with main category = Turtle
  dataLong <- dataLong[which(dataLong$level_1 != "Turtle"),]

  # Remove the "time" column
  dataLong <- subset(dataLong, select = -c(time) )

  # we combine the level_1 and level_2 variables
  dataLong <- reshape(dataLong, varying=c("level_1", "level_2"), direction="long", idvar="commit_sha", sep="_", new.row.names=c(1:10000000))
  #names(dataLong)[8] <- "level"
  dataLong <- dataLong[which(dataLong$level != ""),]
  dataLong <- subset(dataLong, select = c(ID, snapshotId, level))

  # we rename all levels of dataLong$level to make them more readable
  levels(dataLong$level) <- gsub("Enhancement", "A - App enhancement", levels(dataLong$level))
  levels(dataLong$level) <- gsub("NewFeature", "A.1 - New feature", levels(dataLong$level))
  levels(dataLong$level) <- gsub("Changes", "A.2 - Feature changes", levels(dataLong$level))
  levels(dataLong$level) <- gsub("Usability", "A.3 - Usability", levels(dataLong$level))
  levels(dataLong$level) <- gsub("Language", "A.4 - Language", levels(dataLong$level))
  levels(dataLong$level) <- gsub("Lifecycle", "A.5 - Android lifecycle", levels(dataLong$level))
  levels(dataLong$level) <- gsub("Monetization", "A.6 - Monetization", levels(dataLong$level))
  levels(dataLong$level) <- gsub("Utility", "A.7 - Utility", levels(dataLong$level))
  levels(dataLong$level) <- gsub("Bug Fix", "B - Bug fixing", levels(dataLong$level))
  levels(dataLong$level) <- gsub("App Specific", "B.1 - App specific", levels(dataLong$level))
  levels(dataLong$level) <- gsub("Performance", "B.2 - Performance", levels(dataLong$level))
  levels(dataLong$level) <- gsub("Security", "B.3 - Security", levels(dataLong$level))
  levels(dataLong$level) <- gsub("Crash", "B.4 - Crash", levels(dataLong$level))
  levels(dataLong$level) <- gsub("Energy", "B.5 - Energy", levels(dataLong$level))
  levels(dataLong$level) <- gsub("Project management", "C - Project management", levels(dataLong$level))
  levels(dataLong$level) <- gsub("MetaGithub", "C.1 - GitHub-related", levels(dataLong$level))
  levels(dataLong$level) <- gsub("Release", "C.2 - Release management", levels(dataLong$level))
  levels(dataLong$level) <- gsub("TODO", "C.3 - Todo item", levels(dataLong$level))
  levels(dataLong$level) <- gsub("Documentation", "C.4 - Documentation", levels(dataLong$level))
  levels(dataLong$level) <- gsub("Build", "C.5 - Build", levels(dataLong$level))
  levels(dataLong$level) <- gsub("Manifest", "C.6 - Manifest", levels(dataLong$level))
  levels(dataLong$level) <- gsub("IDE", "C.7 - IDE", levels(dataLong$level))
  levels(dataLong$level) <- gsub("Code Re-Organization", "D - Code re-organization", levels(dataLong$level))
  levels(dataLong$level) <- gsub("Refactoring", "D.1 - Refactoring", levels(dataLong$level))
  levels(dataLong$level) <- gsub("Cleanup", "D.2 - Code cleanup", levels(dataLong$level))
  levels(dataLong$level) <- gsub("FeatureRemove", "D.3 - Feature removal", levels(dataLong$level))
  levels(dataLong$level) <- gsub("Resize", "D.4 - Reduce app size", levels(dataLong$level))
  levels(dataLong$level) <- gsub("CodeDead", "D.5 - Dead code elimination", levels(dataLong$level))
  levels(dataLong$level) <- gsub("^UI", "E - User experience improvement", levels(dataLong$level))
  levels(dataLong$level) <- gsub("GUI", "E.1 - GUI", levels(dataLong$level))
  levels(dataLong$level) <- gsub("Strings", "E.2 - Strings", levels(dataLong$level))
  levels(dataLong$level) <- gsub("Icon", "E.3 - Images", levels(dataLong$level))
  levels(dataLong$level) <- gsub("Gesture", "E.4 - Gesture", levels(dataLong$level))
  levels(dataLong$level) <- gsub("Orientation", "E.5 - Orientation", levels(dataLong$level))
  levels(dataLong$level) <- gsub("Dialog", "E.6 - Dialog", levels(dataLong$level))
  levels(dataLong$level) <- gsub("Menu", "E.7 - Menu", levels(dataLong$level))
  levels(dataLong$level) <- gsub("Storage", "F - Storage management", levels(dataLong$level))
  levels(dataLong$level) <- gsub("Settings", "F.1 - Settings", levels(dataLong$level))
  levels(dataLong$level) <- gsub("DB", "F.2 - Local database", levels(dataLong$level))
  levels(dataLong$level) <- gsub("FileSystem", "F.3 - File system", levels(dataLong$level))
  levels(dataLong$level) <- gsub("Sensing & communication", "G - Sensing  & communication", levels(dataLong$level))
  levels(dataLong$level) <- gsub("Networking", "G.1 - Network", levels(dataLong$level))
  levels(dataLong$level) <- gsub("Audio", "G.2 - Audio", levels(dataLong$level))
  levels(dataLong$level) <- gsub("^Image", "G.3 - Image", levels(dataLong$level))
  levels(dataLong$level) <- gsub("Sensors", "G.4 - Sensor", levels(dataLong$level))
  levels(dataLong$level) <- gsub("Camera", "G.5 - Camera", levels(dataLong$level))
  levels(dataLong$level) <- gsub("Messaging", "G.6 - Messaging", levels(dataLong$level))
  levels(dataLong$level) <- gsub("Call", "G.7 - Call", levels(dataLong$level))
  levels(dataLong$level) <- gsub("Mic", "G.8 - Microphone", levels(dataLong$level))
  levels(dataLong$level) <- gsub("API Management", "H - API management", levels(dataLong$level))
  levels(dataLong$level) <- gsub("Library", "H.1 - Library", levels(dataLong$level))
  levels(dataLong$level) <- gsub("API_Android", "H.2 - Android API", levels(dataLong$level))
  levels(dataLong$level) <- gsub("API_REST", "H.3 - REST API", levels(dataLong$level))
  levels(dataLong$level) <- gsub("Deprecation", "H.4 - Deprecation", levels(dataLong$level))
  levels(dataLong$level) <- gsub("^Testing & debugging", "I - Testing & debugging", levels(dataLong$level))
  levels(dataLong$level) <- gsub("^Test", "I.1 - Testing", levels(dataLong$level))
  levels(dataLong$level) <- gsub("Logging", "I.2 - Logging", levels(dataLong$level))
  levels(dataLong$level) <- gsub("Debug", "I.3 - Debugging", levels(dataLong$level))

  # let's order the levels so that they will be ordered also in the heatmap
  dataLong$level <- factor(dataLong$level, levels = sort(as.character(levels(dataLong$level)), decreasing = F))

  # here we select and collect all snapshots which are outlier for each specific maintainability issue type 
  filteredMT <- snapshots[which(snapshots[["outliers.up.mt_density"]] == 1),]
  filteredUS <- snapshots[which(snapshots[["outliers.up.us_density"]] == 1),]
  filteredUI <- snapshots[which(snapshots[["outliers.up.ui_density"]] == 1),]
  filteredMC <- snapshots[which(snapshots[["outliers.up.mc_density"]] == 1),]
  filteredUC <- snapshots[which(snapshots[["outliers.up.uc_density"]] == 1),]
  filteredDP <- snapshots[which(snapshots[["outliers.up.dp_density"]] == 1),]
  # we rename the ID column of each filtered dataframe so that later we can join it with dataLong 
  names(filteredMT)[32] <- "snapshotId"
  names(filteredUS)[32] <- "snapshotId"
  names(filteredUI)[32] <- "snapshotId"
  names(filteredMC)[32] <- "snapshotId"
  names(filteredUC)[32] <- "snapshotId"
  names(filteredDP)[32] <- "snapshotId"

  # we keep only the column containing the snapshot IDs
  filteredMT <- subset(filteredMT, select = c(snapshotId) )
  filteredUS <- subset(filteredUS, select = c(snapshotId) )
  filteredUI <- subset(filteredUI, select = c(snapshotId) )
  filteredMC <- subset(filteredMC, select = c(snapshotId) )
  filteredUC <- subset(filteredUC, select = c(snapshotId) )
  filteredDP <- subset(filteredDP, select = c(snapshotId) )

  # we join the filtered dataframes and the full one by snapshotId, in this way we are selecting all snapshots which are outliers, for each maintainability issue type
  filteredDataLongMT <- inner_join(filteredMT, dataLong, by=c("snapshotId", "snapshotId"))
  filteredDataLongUS <- inner_join(filteredUS, dataLong, by=c("snapshotId", "snapshotId"))
  filteredDataLongUI <- inner_join(filteredUI, dataLong, by=c("snapshotId", "snapshotId"))
  filteredDataLongMC <- inner_join(filteredMC, dataLong, by=c("snapshotId", "snapshotId"))
  filteredDataLongUC <- inner_join(filteredUC, dataLong, by=c("snapshotId", "snapshotId"))
  filteredDataLongDP <- inner_join(filteredDP, dataLong, by=c("snapshotId", "snapshotId"))

  # we add a dedicated column containing the abbreviated name of the issue type
  filteredDataLongMT$IssueType <- factor("MT",levels=rev(c("MT", "US", "UC", "UI", "MC", "DP")))
  filteredDataLongUS$IssueType <- factor("US",levels=rev(c("MT", "US", "UC", "UI", "MC", "DP")))
  filteredDataLongUI$IssueType <- factor("UI",levels=rev(c("MT", "US", "UC", "UI", "MC", "DP")))
  filteredDataLongMC$IssueType <- factor("MC",levels=rev(c("MT", "US", "UC", "UI", "MC", "DP")))
  filteredDataLongUC$IssueType <- factor("UC",levels=rev(c("MT", "US", "UC", "UI", "MC", "DP")))
  filteredDataLongDP$IssueType <- factor("DP",levels=rev(c("MT", "US", "UC", "UI", "MC", "DP")))

  # we bind all filtered dataset, so that we will be ready to build the final heatmap
  labelledTrends <- rbind(filteredDataLongMT, filteredDataLongUS, filteredDataLongUI, filteredDataLongMC, filteredDataLongUC, filteredDataLongDP)

  # Issue types transformed into upper case
  labelledTrends$IssueType <- toupper(labelledTrends$IssueType)

  # each occurrence counts 1
  labelledTrends$value <- 1

  # we remove all unused columns
  labelledTrends <- subset(labelledTrends, select = c(IssueType, level, value))

  # Let's reshape the data from wide to long format
  labelledTrends.long <- melt(labelledTrends, id.vars = c("IssueType", "level"))
  labelledTrends.long$value <- as.numeric(labelledTrends.long$value)

  labelledTrends.long$IssueType <- factor(as.character(labelledTrends.long$IssueType),levels=rev(c("MT", "US", "UC", "UI", "MC", "DP")))

  # custom sum function returns NA when all values in set are NA, 
  # in a set mixed with NAs, NAs are removed and remaining summed.
  # Source: http://www.roymfrancis.com/a-guide-to-elegant-tiled-heatmaps-in-r/
  naSum <- function(x)
  {
    if(all(is.na(x))) val <- sum(x,na.rm=F)
    if(!all(is.na(x))) val <- sum(x,na.rm=T)
    return(val)
  }

  #sums incidences for all weeks into one year
  labelledTrends.long <- ddply(labelledTrends.long,c("IssueType","level"),value=round(naSum(value),0),summarise)

  g <- ggplot(labelledTrends.long,aes(x=level,y=IssueType,fill=value)) +
    #add border white colour of line thickness 0.25
    geom_tile()+
    #redrawing tiles to remove cross lines from legend
    geom_tile(colour="white",size=0.25, show_guide=FALSE)+
    #remove axis labels, add title
    labs(x="",y="",title="")+
    #remove extra space
    scale_y_discrete(expand=c(0,0))+
    scale_fill_gradientn(colours = c("#eef8ed", "#fee08b", "#fdae61", "#d5643f","#d53e4f")) +
    #equal aspect ratio x and y axis
    coord_fixed()+
    #set base size for all font elements
    theme_grey(base_size=10)+
    #theme options
    theme(
      #remove legend title
      legend.title=element_blank(),
      #remove legend margin
      legend.margin = grid::unit(0,"cm"),
      #change legend text properties
      legend.text=element_text(colour="black",size=8,face="plain"),
      #change legend key height
      legend.key.height=grid::unit(0.5,"cm"),
      #set a slim legend
      legend.key.width=grid::unit(0.2,"cm"),
      #set x axis text size and colour and define what should be bold or plain text
      axis.text.x=element_text(size=8,colour="black", angle = 45, hjust = 1, face = rev(c('plain', 'plain', 'plain', 'plain', 'plain',
                                                                                      'bold', 'plain', 'plain', 'plain', 'plain',
                                                                                      'bold', 'plain', 'plain', 'plain', 'plain',
                                                                                      'plain', 'plain', 'bold', 'plain', 'plain',
                                                                                      'plain', 'bold', 'plain', 'plain', 'plain',
                                                                                      'plain', 'plain', 'plain', 'plain', 'bold',
                                                                                      'plain', 'plain', 'plain', 'plain', 'plain',
                                                                                      'bold', 'plain', 'plain', 'plain', 'plain',
                                                                                      'plain', 'plain', 'plain', 'bold', 'plain',
                                                                                      'plain', 'plain', 'plain', 'plain', 'bold',
                                                                                      'plain', 'plain', 'plain', 'plain', 'plain',
                                                                                      'plain', 'plain', 'bold'))),
      #set y axis text colour and adjust vertical justification
      axis.text.y=element_text(size=8, vjust = 0.2, colour="black", face = rev(c('bold', 'plain', 'plain', 'plain', 'plain', 'plain'))),
      #change axis ticks thickness
      axis.ticks=element_line(size=0.4),
      #change title font, size, colour and justification
      plot.title=element_text(colour="black",hjust=0,size=10,face="plain"),
      #remove plot background
      plot.background=element_blank(),
      #remove plot border
      panel.border=element_blank(),
      plot.margin = unit(c(0, 0, 0, 0), "cm")
    )

  # we save the plot into a file
  fileName <- "./plots/commitsTiles.pdf"
  ggsave(fileName, scale = 2.2, height = 3, width = 15, unit = "cm", device=pdf)
  embed_fonts(fileName, outfile=fileName)
}
 
buildTiles()


# Summary statistics for each issue type in the following blocks

s <- subset(snapshots, select = c(ID, shortName, outliers.up.mt_density))
summary(table(s$shortName, s$outliers.up.mt_density)[,2])
sd(table(s$shortName, s$outliers.up.mt_density)[,2])
sd(table(s$shortName, s$outliers.up.mt_density)[,2]) / mean(table(s$shortName, s$outliers.up.mt_density)[,2])
vioplot(table(s$shortName, s$outliers.up.mt_density)[,2])
TOTAL <- table(s$shortName, s$outliers.up.mt_density)

s <- subset(snapshots, select = c(ID, shortName, outliers.up.us_density))
summary(table(s$shortName, s$outliers.up.us_density)[,2])
sd(table(s$shortName, s$outliers.up.us_density)[,2])
sd(table(s$shortName, s$outliers.up.us_density)[,2]) / mean(table(s$shortName, s$outliers.up.us_density)[,2])
vioplot(table(s$shortName, s$outliers.up.us_density)[,2])
TOTAL <- rbind(TOTAL, table(s$shortName, s$outliers.up.us_density))

s <- subset(snapshots, select = c(ID, shortName, outliers.up.uc_density))
summary(table(s$shortName, s$outliers.up.uc_density)[,2])
sd(table(s$shortName, s$outliers.up.uc_density)[,2])
sd(table(s$shortName, s$outliers.up.uc_density)[,2]) / mean(table(s$shortName, s$outliers.up.uc_density)[,2])
vioplot(table(s$shortName, s$outliers.up.uc_density)[,2])
TOTAL <- rbind(TOTAL, table(s$shortName, s$outliers.up.uc_density))

s <- subset(snapshots, select = c(ID, shortName, outliers.up.ui_density))
summary(table(s$shortName, s$outliers.up.ui_density)[,2])
sd(table(s$shortName, s$outliers.up.ui_density)[,2])
sd(table(s$shortName, s$outliers.up.ui_density)[,2]) / mean(table(s$shortName, s$outliers.up.ui_density)[,2])
vioplot(table(s$shortName, s$outliers.up.ui_density)[,2])
TOTAL <- rbind(TOTAL, table(s$shortName, s$outliers.up.ui_density))

s <- subset(snapshots, select = c(ID, shortName, outliers.up.mc_density))
summary(table(s$shortName, s$outliers.up.mc_density)[,2])
sd(table(s$shortName, s$outliers.up.mc_density)[,2])
sd(table(s$shortName, s$outliers.up.mc_density)[,2]) / mean(table(s$shortName, s$outliers.up.mc_density)[,2])
vioplot(table(s$shortName, s$outliers.up.mc_density)[,2])
TOTAL <- rbind(TOTAL, table(s$shortName, s$outliers.up.mc_density))

s <- subset(snapshots, select = c(ID, shortName, outliers.up.dp_density))
summary(table(s$shortName, s$outliers.up.dp_density)[,2])
sd(table(s$shortName, s$outliers.up.dp_density)[,2])
sd(table(s$shortName, s$outliers.up.dp_density)[,2]) / mean(table(s$shortName, s$outliers.up.dp_density)[,2])
vioplot(table(s$shortName, s$outliers.up.dp_density)[,2])
TOTAL <- rbind(TOTAL, table(s$shortName, s$outliers.up.dp_density))


