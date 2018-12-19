#!/bin/bash
#
#
#SBATCH -J min163k
#SBATCH -N 1
#SBATCH -n 1
#SBATCH -p skx-normal
#SBATCH -t 15:00:00
#SBATCH -A Envriotype
#SBATCH -o job_%j_%N.out
#------------------------------------------------------
mkdir -p output4
Rscript --verbose ./prem_workflow4.R > ./output.Rout