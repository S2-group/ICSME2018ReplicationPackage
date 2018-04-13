library(extrafont)
library(dplyr)
library(plyr)
library(tibble)
library(reshape2)
library(RColorBrewer)
require(grid)

loadfonts()

# RQ2.1

# let's read the manually-tagged data
labelledTrends <- read.csv(file="./labelledData/labelled_trends.csv", head=TRUE, sep=",", stringsAsFactors=TRUE)

# Renaming Tag_id -> level_2 and MacroCategory -> level_1
names(labelledTrends)[2] <- "level_2"
names(labelledTrends)[3] <- "level_1"

# move all the issue type tags to upper case
labelledTrends$IssueType <- toupper(labelledTrends$IssueType)

# create an ID column in labelledTrends
labelledTrends$ID <- seq.int(nrow(labelledTrends))

# set the count for each labelled trend to 1
labelledTrends$value <- 1

# filter the columns that we do not use
labelledTrends <- subset(labelledTrends, select = c(IssueType, level_1, level_2, value))

# Let's reshape the data from wide to long format
labelledTrends.long <- melt(labelledTrends, id.vars = c("IssueType", "level_2"))

# the value column of labelledTrends is numeric
labelledTrends.long$value <- as.numeric(labelledTrends.long$value)

# the IssueType column of labelledTrends is categorical
labelledTrends.long$IssueType <- factor(as.character(labelledTrends.long$IssueType), levels=rev(c("MT", "US", "UC", "UI", "MC", "DP")))

# Renaming: we change the names of the level_2 column to the ones we will use in the paper
labelledTrends.long$level_2 <- revalue(labelledTrends.long$level_2, c("C" = "C", "D" = "D", "DP" = "DP", "F" = "A", "H" = "H", "I" = "I", "IH" = "V", "IP" = "IP", "PD" = "PD", "PI" = "PI", "SD" = "SD", "SI" = "SI"))

# the level_2 column of labelledTrends is categorical
labelledTrends.long$level_2 <- factor(as.character(labelledTrends.long$level_2),levels=c("I", "SI", "IP", "PI", "D", "SD", "DP", "PD", "H", "V", "A", "C"))  
# the rows with level_2 == NA are all constant trends
labelledTrends.long$level_2[is.na(labelledTrends.long$level_2)] <- "C"

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
labelledTrends.long <- ddply(labelledTrends.long,c("IssueType","level_2"),value=round(naSum(value),0),summarise)

# Let's build the heatmap
g <- ggplot(labelledTrends.long,aes(x=level_2,y=IssueType,fill=value)) + 
  #add border white colour of line thickness 0.25
  geom_tile()+
  #redrawing tiles to remove cross lines from legend
  geom_tile(colour="white",size=0.25, show_guide=FALSE)+
  #remove axis labels, add title
  labs(x="",y="",title="")+
  #remove extra space
  scale_y_discrete(expand=c(0,0))+
  #custom colours for cut levels and na values
  scale_fill_gradientn(colours = c("#ddf1da","#e6f598", "#fee08b","#fdae61","#d53e4f")) +
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
    legend.text=element_text(colour="black",size=10,face="plain"),
    #change legend key height
    legend.key.height=grid::unit(0.8,"cm"),
    #set a slim legend
    legend.key.width=grid::unit(0.2,"cm"),
    #set x axis text size and colour
    axis.text.x=element_text(size=10,colour="black"),
    #set y axis text colour and adjust vertical justification
    axis.text.y=element_text(size=10, vjust = 0.2,colour="black", face = rev(c('bold', 'plain', 'plain', 'plain', 'plain', 'plain'))),
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

# We save the results into a file
fileName <- "./plots/trendsTiles.pdf"
ggsave(fileName, scale = 2.2, height = 3, width = 6, unit = "cm", device=pdf)
embed_fonts(fileName, outfile=fileName)

# we get the previously built decomposition of the time series of the __issueName__ of the app with __appName__ and we plot its trend component
getPlotTrend <- function(appName, issueName, issueHumanName, fileName, xlab, ylab) {
  # we get the row corresponding to the app with appName
  app <- apps[which(apps$shortName == appName),]
  
  # we get the decomposition and we extract its original time series and trend component, we put everything into the df dataframe
  stlModel <- app[[paste0("modelstl.", issueName)]][[1]]
  ts <- snapshots[which(snapshots$shortName == appName),][[issueName]]
  trend <- stlModel$time.series[,2]
  weeks <- seq.int(length(ts))
  df <- data.frame(weeks,ts, trend) 
  
  # we build the plot containing both the original time series (in dashed blue) and its trend component (in solid black)
  ggplot(df, aes(x = weeks)) + geom_line(aes(y=ts), linetype="dashed", color='steelblue' ) + 
    geom_line(aes(y=trend)) + 
    labs(x=xlab, y=ylab, fill="Data") +
    theme_light() +
    scale_x_continuous(breaks = unique(df$weeks), labels = c()) +
    scale_y_continuous(breaks = c(), labels = c()) + #, limits = c(0, max(ts))) +
    theme(axis.ticks.x=element_blank(), plot.margin=grid::unit(c(2,0,0,0), "mm"), axis.title=element_text(size=9)) +
    guides(fill=FALSE)
  
  # we save the plot into a file
  ggsave(fileName, scale = 1.5, height = 2, width = 3, unit = "cm", device=pdf)
  embed_fonts(fileName, outfile=fileName)
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

# we plot the time series related to the issue called issueName of app appName and print its identified outliers
getPlot <- function(appName, issueName, issueHumanName, fileName, xlab, ylab) {
  app <- apps[which(apps$shortName == appName),]
  
  # we get the decomposition and we extract its original time series and trend component, we put everything into the df dataframe
  stlModel <- app[[paste0("modelstl.", issueName)]][[1]]
  ts <- snapshots[which(snapshots$shortName == appName),][[issueName]]
  trend <- stlModel$time.series[,2]
  weeks <- seq.int(length(ts))
  df <- data.frame(weeks,ts, trend) 
  
  # we get the outliers
  outliers <- identifyOutliers(snapshots[which(snapshots$shortName == appName),][[issueName]], "up")
  print(outliers)
  
  # we plot the time series
  ggplot(df, aes(x = weeks)) + geom_line(aes(y=ts)) + 
    labs(x=xlab, y=ylab, fill="Data") +
    ylim(0, max(ts)) +
    theme_light() +
    scale_x_continuous(breaks = unique(df$weeks), labels = c()) +
    theme(axis.ticks.x=element_blank(), plot.margin=grid::unit(c(2,0,0,0), "mm"), axis.title=element_text(size=9), axis.text.y = element_text(size=9)) +
    guides(fill=FALSE)
  
  # we save the plot into a file
  ggsave(fileName, scale = 2, height = 2, width = 3, unit = "cm", device=pdf)
  embed_fonts(fileName, outfile=fileName)
}

appsToPlot <- c("ADCPU-16Emu",
                "AttysScope",
                "SGit",
                "AndroidBootcampProject",
                "BitcoinChecker",
                "Ursmu",
                "BirdWalk",
                "MLManager",
                "CineTime",
                "RadyoMenemenPro",
                "PixelDungRemix",
                "android-simple-gameapi")

plotTypes <- c("I", "SI", "IP", "PI", "D", "SD", "DP", "PD", "H", "V", "A", "C")

# for each app to plot, we create its plot 
for(i in 1:(length(appsToPlot)-1)) {
  getPlotTrend(appsToPlot[i], "mt_density", "MT", paste0("./plots/", paste0("trends_", as.character(i)), ".pdf"), paste0(appsToPlot[i], " (", plotTypes[i], ")"), "")
}
getPlotTrend("android-simple-gameapi", "uc_density", "MT", paste0("./plots/", paste0("trends_", 12), ".pdf"), paste0("android-simple-gameapi", " (C)"), "")

