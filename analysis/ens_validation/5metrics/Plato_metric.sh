#!/bin/bash

#! Define configuration flags
# See: https://www.acrc.bris.ac.uk/protected/bc4-docs/scheduler/index.html

#SBATCH --job-name=metric
#SBATCH --time=0-3:0:0
#SBATCH --cpus-per-task=1
#SBATCH --mem=10G

#! add the MATLAB module (as per BCp4)
module load matlab/R2017b
#! Run the job
matlab -nodisplay -r metric_cal