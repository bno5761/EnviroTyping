#install the following packages if you have not already
#library(profr)
library(PReMiuM)
#library(ggplot2)
library(dplyr)
################
set.seed(1234)
prem.bench <- function(){

  #create list of function names for each distribution. Will later be called to generate the sample data#
  #
  function.list = c("clusSummaryBernoulliDiscrete", "clusSummaryBernoulliNormal", "clusSummaryBernoulliDiscreteSmall","clusSummaryCategoricalDiscrete","clusSummaryNormalDiscrete","clusSummaryNormalNormal","clusSummaryNormalNormalSpatial","clusSummaryVarSelectBernoulliDiscrete","clusSummaryBernoulliMixed")

  #set up the final output variable#
  
  final.out = list()
  #
  #for loop runs the premium functions on each distribution and outputs the optimal cluster, Y value, and known truth cluster for all elements in each distribution's sample data.

  for(i in function.list){

    #set seed for consistent results among all distributions#
    #
    set.seed(0001)

    #run the function to generate the sample data using the name of the distribution from the function list.
    #
    inputs = do.call("generateSampleDataFile",list(do.call(i,list())))

    # check if an output directory exists and and change to it for premium ouput files or create a new one and change if necessary
    if (dir.exists(paste(getwd(),"output", sep = "/"))) {
        setwd(paste(getwd(),"output", sep = "/"))
    } else {
        dir.create(paste(getwd(),"output", sep = "/"))
        setwd("./output")
    }


    #multiple 'if' statements to determine which parameters need to be filled in. Some distributions have more parameters than others.
    #
    if (exists("fixedEffectsNames",where = inputs)){
      runInfoObj<-profRegr(yModel=inputs$yModel, xModel=inputs$xModel, nSweeps=100, nClusInit=15,nBurn=300, data=inputs$inputData, output="output",covNames = inputs$covNames,fixedEffectsNames = inputs$fixedEffectNames, seed=12345)
    } else {
      if (exists("discreteCovs",where = inputs)){
        runInfoObj<-profRegr(yModel=inputs$yModel, xModel=inputs$xModel, nSweeps=100, nClusInit=15,nBurn=300, data=inputs$inputData, output="output",covNames = inputs$covNames,discreteCovs = inputs$discreteCovs, continuousCovs = inputs$continuousCovs, seed=12345)
      } else {
        runInfoObj<-profRegr(yModel=inputs$yModel, xModel=inputs$xModel, nSweeps=100, nClusInit=15,nBurn=300, data=inputs$inputData, output="output",covNames = inputs$covNames, seed=12345)
      }
    }

    #the rest of the PReMiuM steps to get the optimal clustering
    #
    dissimObj<-calcDissimilarityMatrix(runInfoObj)
    clusObj<-calcOptimalClustering(dissimObj,maxNClusters =7)
    riskProfileObj<-calcAvgRiskAndProfile(clusObj)
    clusterOrderObj<-plotRiskProfile(riskProfileObj,"summary2.png")
    optAlloc<-clusObj$clustering
    classNum <- n_distinct(optAlloc)
    #directly pull the population size from each generated sample sicne they are different for each distribution
    #
    popSize = dim(inputs$inputData)[1]

    #use the population size/number of clusters to create randomly sized clusters that add up to the population total
    #
    clusSizes = c(sample(1:classNum,popSize,replace = TRUE,prob = c(sample(20:80, classNum,replace = TRUE)/100)))
    table(clusSizes)

    #create a vector 'known' that repeats "Known 1", "Known 2", etc for the total amount in known cluster 1, known cluster 2, etc.
    #
    known = NULL
    for (j in 1:classNum){
        newdat = rep(paste("Known",j),table(clusSizes)[j])
        known = c(known, newdat)
    }

    #creates a data frame with the optimal clusters, Y values for the simulated data, and the known truth clusters
    #
    tmp_df<-data.frame(opt=as.factor(optAlloc),outcome=inputs$inputData$outcome,known=as.factor(known))

    #combine the output of the current distribution with the previous distribution, so the final output is one a list of dataframes for each distribution
    #
    final.out[[i]] = tmp_df
  }
  return(final.out)
}

#run the function, save output as 'tester'
#
tester = prem.bench()

#Seperate each distribution's output by the name of distribution.
#
BernoulliDiscrete = tester$clusSummaryBernoulliDiscrete
BernoulliNormal = tester$clusSummaryBernoulliNormal
BernoulliDiscreteSmall = tester$clusSummaryBernoulliDiscreteSmall
CategoricalDiscrete = tester$clusSummaryCategoricalDiscrete
NormalDiscrete = tester$clusSummaryNormalDiscrete
NormalNormal = tester$clusSummaryNormalNormal
NormalNormalSpatial = tester$clusSummaryNormalNormalSpatial
VarSelectBernoulliDiscrete = tester$clusSummaryVarSelectBernoulliDiscrete
BernoulliMixed = tester$clusSummaryBernoulliMixed

# Compare the known truths to the Premium clustering output
#
table(BernoulliDiscrete$known,BernoulliDiscrete$opt)
table(BernoulliNormal$known, BernoulliNormal$opt)
table(BernoulliDiscreteSmall$known, BernoulliDiscreteSmall$opt)
table(CategoricalDiscrete$known, CategoricalDiscrete$opt)
table(NormalDiscrete$known, NormalDiscrete$opt)
table(NormalNormal$known,NormalNormal$opt)
table(NormalNormalSpatial$known, NormalNormalSpatial$opt)
table(VarSelectBernoulliDiscrete$known, VarSelectBernoulliDiscrete$opt)
table(BernoulliMixed$known, BernoulliMixed$opt)

save.image("tester.Rdata", compress = "xz")
