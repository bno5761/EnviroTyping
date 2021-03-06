library(PReMiuM)
library(tidyverse)
library(tictoc)

setwd("/work/04902/azg5169/stampede2/EnviroTyping/sandbox/na_data_analysis/2015/min_vars_3000/output")

df <- read_rds("../../../../../data/interim/2015/hyb_by_mon_calib_w_wth_nas.rds")

variance_var <- names(which(map_dbl(df[,16:length(df)], var, na.rm = TRUE) != 0))
min_vars <- str_subset(variance_var, "min")

set.seed(12345)
tic()
runInfoObj <- profRegr(covNames, outcome = 'yield', yModel = 'Normal', xModel = "Mixed", discreteCovs = "pedi", continuousCovs = min_vars, data = df, nSweeps = 3000, nBurn = 50, nProgress = 100, nClusInit = 1000, seed = 12345)
toc()
calcDists <- calcDissimilarityMatrix(runInfoObj)
clusObj <- calcOptimalClustering(calcDists)
write_rds(clusObj, "../clusObj.rds", compress = "xz")

