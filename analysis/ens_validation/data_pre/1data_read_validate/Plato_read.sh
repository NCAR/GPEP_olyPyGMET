#!/bin/bash

#! Define configuration flags
# See: https://www.acrc.bris.ac.uk/protected/bc4-docs/scheduler/index.html

#SBATCH --job-name=assemble 
#SBATCH --time=0-2:0:0
#SBATCH --mem-per-cpu=5G

#! add the MATLAB module (as per BCp4)
module load matlab/R2017b
#! Run the job
matlab -nodisplay -r GHCN_read_plato