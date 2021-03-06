library(PReMiuM)
library(tidyverse)

setwd("/work/04902/azg5169/stampede2/EnviroTyping/sandbox/na_data_analysis/2014/min_vars_3000/output")

df <- read_rds("../../../../../data/interim/2014/hyb_by_mon_calib_w_wth_nas.rds")

df = df[is.na(df$yield) == FALSE,]

variance.var <- names(which(map_dbl(df[,16:length(df)], var, na.rm = TRUE) != 0))
min.vars <- str_subset(names(df[,16:length(df)]), "min")

set.seed(1234);
runInfoObj <- profRegr(covNames, outcome = 'yield', yModel = 'Normal', xModel = "Mixed", discreteCovs = "pedi", continuousCovs = min.vars, data = df, nSweeps = 3000, nBurn = 50, nProgress = 100, nClusInit = 1000, seed = 2435)
calcDists <- calcDissimilarityMatrix(runInfoObj)
clusObj <- calcOptimalClustering(calcDists)
riskProfObj <- calcAvgRiskAndProfile(clusObj)
write_rds(riskProfObj, "../riskProfObj.rds")
write_rds(clusObj, "../clusObj.rds", compress = "xz")

