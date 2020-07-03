#!/bin/bash

#! Define configuration flags
# See: https://www.acrc.bris.ac.uk/protected/bc4-docs/scheduler/index.html

#SBATCH --job-name=relia
#SBATCH --time=0-1:0:0
#SBATCH --cpus-per-task=10
#SBATCH --mem=20G

#! add the MATLAB module (as per BCp4)
module load matlab/R2017b
#! Run the job
matlab -nodisplay -r plot_reliability