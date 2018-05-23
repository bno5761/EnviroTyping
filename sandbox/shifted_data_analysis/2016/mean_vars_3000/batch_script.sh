#!/bin/bash
#
#
#SBATCH -J mean_3000
#SBATCH -N 1
#SBATCH -n 1
#SBATCH -p skx-normal
#SBATCH -t 48:00:00
#SBATCH -A Envriotype
#SBATCH -o job_%j_%N.out
#------------------------------------------------------
mkdir output
Rscript --vanilla --verbose ./prem_workflow.R > ./output.Rout