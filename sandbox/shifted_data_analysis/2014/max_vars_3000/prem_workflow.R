library(PReMiuM)
library(tidyverse)

setwd("/work/04734/dhbrand/stampede2/github/EnviroTyping/sandbox/shifted_data_analysis/2014/max_vars_3000/output")

df <- read_rds("../../../../../data/interim/2014/hyb_by_mon_calib_wide_shifted.rds")

variance.var <- names(which(map_dbl(df[,17:207], var, na.rm = TRUE) != 0))
max.vars <- str_subset(variance.var, "max")

set.seed(1234)
runInfoObj <- profRegr(covNames, outcome = 'yield', yModel = 'Normal', xModel = "Mixed", discreteCovs = "pedi", continuousCovs = max.vars, data = df, nSweeps = 3000, nBurn = 50, nProgress = 100, nClusInit = 1000)
calcDists <- calcDissimilarityMatrix(runInfoObj)
clusObj <- calcOptimalClustering(calcDists)
riskProfObj <- calcAvgRiskAndProfile(clusObj)
write_rds(riskProfObj, "../riskProfObj.rds", compress = "xz")

