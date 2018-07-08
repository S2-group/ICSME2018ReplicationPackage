# How Maintainability Issues of Android Apps Evolve: Replication Package (ICSME 2018)
This repository is a companion page for the paper "How Maintainability Issues of Android Apps Evolve" accepted for publication at the International conference on Software Maintenance and Evolution ([ICSME 2018](https://icsme2018.github.io/)).

It contains all the material required to replicate our analysis, including (i) the raw input data (ii) the statistical analysis scripts, and (iii) the analysis results in form of data, plots, etc. Some additional analyses and results, not included in the paper due to space limitations, are also provided.


Analysis replication
---------------
The totality of the statistical analysis scripts utilized for the study are available [here](https://github.com/ICSME/ReplicationPackage2018/tree/master/analysis)
In order to replicate the analysis of the study (i) clone the repository (`git clone https://github.com/ICSME/ReplicationPackage2018`) and (ii) execute the analysis scripts in the following order.

1. [dataLoader.r](https://github.com/ICSME/ReplicationPackage2018/tree/master/analysis/dataLoader.r) - Load the .csv files containing the raw data
2. [RQ1_analysis.r](https://github.com/ICSME/ReplicationPackage2018/tree/master/analysis/RQ1_analysis.r) - Perform all analysis and plotting processes related to RQ1 
3. [RQ2_tsAnalysis.r](https://github.com/ICSME/ReplicationPackage2018/tree/master/analysis/RQ2_tsAnalysis.r) - Build the time series, their decompositions, and plots (preliminary for the other steps)
4. [RQ2_tsStationality.r](https://github.com/ICSME/ReplicationPackage2018/blob/master/analysis/RQ2_tsStationality.r) - Check and store the stationarity of the time series of each app for each maintainability issue
5. [RQ2_analysis.r](https://github.com/ICSME/ReplicationPackage2018/tree/master/analysis/RQ2_analysis.r) - Perform all analysis and plotting activities related to RQ2
6. [RQ3_outlierCommitFilter.r](https://github.com/ICSME/ReplicationPackage2018/tree/master/analysis/RQ3_outlierCommitFilter.r) - Identify and filter the commits belonging to maintainability hotspots for each type of maintainability issue
7. [RQ3_analysis.r](https://github.com/ICSME/ReplicationPackage2018/blob/master/analysis/RQ3_analysis.R) - Perform all analysis and plotting activities related to RQ3

Raw input Data
---------------
The raw input data utilized for the statistical analysis is available [here](https://github.com/ICSME/ReplicationPackage2018/tree/master/data)
Specifically, the analyzed dataset is composed of the following files:
* [apps.csv](https://github.com/ICSME/ReplicationPackage2018/tree/master/data/apps.csv) - Dataset containing demographic information of the Android application considered 
* [commits.csv](https://github.com/ICSME/ReplicationPackage2018/tree/master/data/commits.csv) - Dataset containing the entirety of the commits messages of the applications considered
* [snapshots.csv](https://github.com/ICSME/ReplicationPackage2018/tree/master/data/snapshots.csv) - Dataset containing the evolutionary data of the application considered, such as the maintainability issue density.

Results and plots
---------------
The results produced in order to answer our research question are provided [here](https://github.com/ICSME/ReplicationPackage2018/tree/master/analysis/results).
The totality of the plots generated during the analysis processes are instead provided [here](https://github.com/ICSME/ReplicationPackage2018/tree/master/analysis/plots). This includes also diagrams which, due to space limitations, were not included in the paper.

Directory Structure Overview
---------------
This reposisory is structured as follows:

    ReplicationPackage2018
     .
     |
     |--- analysis/         Input of the algorithms, i.e. fault matrix, coverage information, and BB representation of subjects.
     |      |
     |      |
     |      |--- plots/     Plots generated for the analysis processes. 
     |      |
     |      |--- results/   Raw output data generated from the analysis.
     |
     |
     |--- data/             Raw input data of the analysis processes.
     |
     |--- labelledData/     Commits labelled according to the manual labelling process
     
  
