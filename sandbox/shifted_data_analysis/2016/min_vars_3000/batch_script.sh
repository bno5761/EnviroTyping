#!/bin/bash
#
#
#SBATCH -J min163k
#SBATCH -N 1
#SBATCH -n 1
#SBATCH -p skx-normal
#SBATCH -t 15:00:00
#SBATCH -A Envriotype
#SBATCH --mail-type=ALL
#SBATCH --mail-user=azg5169@azg5169.com
#SBATCH -o job_%j_%N.out
#------------------------------------------------------
mkdir output
Rscript --verbose ./prem_workflow.R > ./output.Rout
