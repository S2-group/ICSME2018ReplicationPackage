library(vioplot)

# kruskal omnibus test with Bonferroni adjustment. This test is utilized in adopted to understand if a statisticaly significant difference is present between the maintainability issue types distributions. 
# the significance level is automatically adjusted by means of Bonferroni correction.
kruskal_test_data = list(snapshots$us_density, snapshots$uc_density, snapshots$ui_density, snapshots$mc_density, snapshots$dp_density)
kruskal.test(kruskal_test_data, p.adj="bonferroni")

# pairwise Mann-Whitney test between the maintainabiity issue type distribution.
# this set of tests is utilized in order to understand if a statistically significant difference is present between each pair of maintainability issue distributions.
# the significance level is manually adjusted by means of Bonferroni correction in order to take into account the totality of pairwise conducted (i.e. 10 tests).
wilcox.test(snapshots$us_density, snapshots$ui_density, p=0.005)
wilcox.test(snapshots$us_density, snapshots$uc_density, p=0.005)
wilcox.test(snapshots$us_density, snapshots$mc_density, p=0.005)
wilcox.test(snapshots$us_density, snapshots$dp_density, p=0.005)
wilcox.test(snapshots$ui_density, snapshots$uc_density, p=0.005)
wilcox.test(snapshots$ui_density, snapshots$mc_density, p=0.005)
wilcox.test(snapshots$ui_density, snapshots$dp_density, p=0.005)
wilcox.test(snapshots$uc_density, snapshots$mc_density, p=0.005)
wilcox.test(snapshots$uc_density, snapshots$dp_density, p=0.005)
wilcox.test(snapshots$mc_density, snapshots$dp_density, p=0.005)

# pairwise Mann-Whitney test with Bonferroni adjustment to compare maintainability aggregate to duplication category.
# additional pairwise test used to compare the Maintainability macro-category to the maintainability issue with the most similar distribution.
# this test was adopted to understand by statistical means the similarity between the two distributions considered.
# as for the previous tests, the p-value was adjusted through the Bonferroni correction
wilcox.test(snapshots$mt_density, snapshots$dp_density, p=0.05)

# print to terminal the summaries of maintainability issue types in order to efficiently calculate mean and median values of their distributions
summary(snapshots$us_density)
summary(snapshots$uc_density)
summary(snapshots$ui_density)
summary(snapshots$mc_density)
summary(snapshots$dp_density)


# we now rerun the tests on the aggregated data per app. The mean values are considered for the aggregation in this additional analysis
# the first step consists in aggregating the data we are interested in (i.e. the issue densities per app).
aggregated_snapshots <- aggregate(snapshots[, 22:28], list(snapshots$shortName), mean)

# we then execute again the previous statistical analysis on the aggregated dataset
# kruskal omnibus test with Bonferroni adjustment. This test is utilized in adopted to understand if a statisticaly significant difference is present between the maintainability issue types distributions. 
# the significance level is automatically adjusted by means of Bonferroni correction.
kruskal_test_data = list(aggregated_snapshots$us_density, aggregated_snapshots$uc_density, aggregated_snapshots$ui_density, aggregated_snapshots$mc_density, aggregated_snapshots$dp_density)
kruskal.test(kruskal_test_data, p.adj="bonferroni")

# pairwise Mann-Whitney test between the maintainabiity issue type distribution.
# this set of tests is utilized in order to understand if a statistically significant difference is present between each pair of maintainability issue distributions.
# the significance level is manually adjusted by means of Bonferroni correction in order to take into account the totality of pairwise conducted (i.e. 10 tests).
wilcox.test(aggregated_snapshots$us_density, aggregated_snapshots$ui_density, p=0.005)
wilcox.test(aggregated_snapshots$us_density, aggregated_snapshots$uc_density, p=0.005)
wilcox.test(aggregated_snapshots$us_density, aggregated_snapshots$mc_density, p=0.005)
wilcox.test(aggregated_snapshots$us_density, aggregated_snapshots$dp_density, p=0.005)
wilcox.test(aggregated_snapshots$ui_density, aggregated_snapshots$uc_density, p=0.005)
wilcox.test(aggregated_snapshots$ui_density, aggregated_snapshots$mc_density, p=0.005)
wilcox.test(aggregated_snapshots$ui_density, aggregated_snapshots$dp_density, p=0.005)
wilcox.test(aggregated_snapshots$uc_density, aggregated_snapshots$mc_density, p=0.005)
wilcox.test(aggregated_snapshots$uc_density, aggregated_snapshots$dp_density, p=0.005)
wilcox.test(aggregated_snapshots$mc_density, aggregated_snapshots$dp_density, p=0.005)

# pairwise Mann???Whitney test with Bonferroni adjustment to compare maintainability aggregate to duplication category.
# additional pairwise test used to compare the Maintainability macro-category to the maintainability issue with the most similar distribution.
# this test was adopted to understand by statistical means the similarity between the two distributions considered.
# as for the previous tests, the p-value was adjusted through the Bonferroni correction
wilcox.test(aggregated_snapshots$mt_density, aggregated_snapshots$dp_density, p=0.05)

# print to terminal the summaries of maintainability issue types in order to efficiently calculate mean and median values of their distributions
summary(aggregated_snapshots$us_density)
summary(aggregated_snapshots$uc_density)
summary(aggregated_snapshots$ui_density)
summary(aggregated_snapshots$mc_density)
summary(aggregated_snapshots$dp_density)


# customized function of the vioplot package in order to display multiple colors in the same diagram
vioplot <- function(x,...,range=1.5,h=NULL,ylim=NULL,names=NULL, horizontal=FALSE,
                    col="magenta", border="black", lty=1, lwd=1, rectCol="black", colMed="white", pchMed=19, at, add=FALSE, wex=1,
                    drawRect=TRUE)
{
  # process multiple datas
  datas <- list(x,...)
  n <- length(datas)
  
  if(missing(at)) at <- 1:n
  
  # pass 1
  #
  # - calculate base range
  # - estimate density
  #
  
  # setup parameters for density estimation
  upper  <- vector(mode="numeric",length=n)
  lower  <- vector(mode="numeric",length=n)
  q1     <- vector(mode="numeric",length=n)
  q3     <- vector(mode="numeric",length=n)
  med    <- vector(mode="numeric",length=n)
  base   <- vector(mode="list",length=n)
  height <- vector(mode="list",length=n)
  baserange <- c(Inf,-Inf)
  
  # global args for sm.density function-call
  args <- list(display="none")
  
  if (!(is.null(h)))
    args <- c(args, h=h)
  
  for(i in 1:n) {
    data<-datas[[i]]
    
    # calculate plot parameters
    #   1- and 3-quantile, median, IQR, upper- and lower-adjacent
    data.min <- min(data)
    data.max <- max(data)
    q1[i]<-quantile(data,0.25)
    q3[i]<-quantile(data,0.75)
    med[i]<-median(data)
    iqd <- q3[i]-q1[i]
    upper[i] <- min( q3[i] + range*iqd, data.max )
    lower[i] <- max( q1[i] - range*iqd, data.min )
    
    #   strategy:
    #       xmin = min(lower, data.min))
    #       ymax = max(upper, data.max))
    #
    
    est.xlim <- c( min(lower[i], data.min), max(upper[i], data.max) )
    
    # estimate density curve
    smout <- do.call("sm.density", c( list(data, xlim=est.xlim), args ) )
    
    # calculate stretch factor
    #
    #  the plots density heights is defined in range 0.0 ... 0.5
    #  we scale maximum estimated point to 0.4 per data
    #
    hscale <- 0.4/max(smout$estimate) * wex
    
    # add density curve x,y pair to lists
    base[[i]]   <- smout$eval.points
    height[[i]] <- smout$estimate * hscale
    
    # calculate min,max base ranges
    t <- range(base[[i]])
    baserange[1] <- min(baserange[1],t[1])
    baserange[2] <- max(baserange[2],t[2])
    
  }
  
  # pass 2
  #
  # - plot graphics
  
  # setup parameters for plot
  if(!add){
    xlim <- if(n==1)
      at + c(-.5, .5)
    else
      range(at) + min(diff(at))/2 * c(-1,1)
    
    if (is.null(ylim)) {
      ylim <- baserange
    }
  }
  if (is.null(names)) {
    label <- 1:n
  } else {
    label <- names
  }
  
  boxwidth <- 0.05 * wex
  
  # setup plot
  if(!add)
    plot.new()
  if(!horizontal) {
    if(!add){
      plot.window(xlim = xlim, ylim = ylim)
      axis(2)
      axis(1,at = at, label=label )
    }
    
    box()
    for(i in 1:n) {
      # plot left/right density curve
      polygon( c(at[i]-height[[i]], rev(at[i]+height[[i]])),
               c(base[[i]], rev(base[[i]])),
               col = col[i %% length(col) + 1], border=border, lty=lty, lwd=lwd)
      
      if(drawRect){
        # plot IQR
        lines( at[c( i, i)], c(lower[i], upper[i]) ,lwd=lwd, lty=lty)
        
        # plot 50% KI box
        rect( at[i]-boxwidth/2, q1[i], at[i]+boxwidth/2, q3[i], col=rectCol)
        
        # plot median point
        points( at[i], med[i], pch=pchMed, col=colMed )
      }
    }
    
  }
  else {
    if(!add){
      plot.window(xlim = ylim, ylim = xlim)
      axis(1)
      axis(2,at = at, label=label )
    }
    
    box()
    for(i in 1:n) {
      # plot left/right density curve
      polygon( c(base[[i]], rev(base[[i]])),
               c(at[i]-height[[i]], rev(at[i]+height[[i]])),
               col = col[i %% length(col) + 1], border=border, lty=lty, lwd=lwd)
      
      if(drawRect){
        # plot IQR
        lines( c(lower[i], upper[i]), at[c(i,i)] ,lwd=lwd, lty=lty)
        
        # plot 50% KI box
        rect( q1[i], at[i]-boxwidth/2, q3[i], at[i]+boxwidth/2,  col=rectCol)
        
        # plot median point
        points( med[i], at[i], pch=pchMed, col=colMed )
      }
    }
  }
  invisible (list( upper=upper, lower=lower, median=med, q1=q1, q3=q3))
}


# plot violin plots of issue density per type of issue of the totality of the snapshots
vioplot(snapshots$mt_density, snapshots$us_density, snapshots$uc_density, snapshots$ui_density, snapshots$mc_density, snapshots$dp_density, names=c("Maintainability violations", "Unit size violation", "Unit complexity violation", "Unit interfacing violation", "Module copuling violation", "Duplication violation"), col = c("lightblue", "#fca344","lightblue","lightblue","lightblue","lightblue"))
title(ylab="Number of issues", xlab="Issue type")
grid(NULL, lty = 20, col = "grey", nx=0)

# plot violin plots of issue density per type of issue of the aggregated snapshots per app
vioplot(aggregated_snapshots$mt_density, aggregated_snapshots$us_density, aggregated_snapshots$uc_density, aggregated_snapshots$ui_density, aggregated_snapshots$mc_density, aggregated_snapshots$dp_density, names=c("Maintainability violations", "Unit size violation", "Unit complexity violation", "Unit interfacing violation", "Module copuling violation", "Duplication violation"), col = c("lightblue", "#fca344","lightblue","lightblue","lightblue","lightblue"))
title(ylab="Number of issues", xlab="Issue type")
grid(NULL, lty = 20, col = "grey", nx=0)
