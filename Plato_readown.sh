#!/bin/bash

#! Define configuration flags
# See: https://www.acrc.bris.ac.uk/protected/bc4-docs/scheduler/index.html

#SBATCH --job-name=readown
#SBATCH --time=1-00:00:00
#SBATCH --mem-per-cpu=20G

#! add the python module
module load python/3.7.4

# run the application
srun python reanalysis_downscale.py $((${SLURM_ARRAY_TASK_ID}+1978)) $((${SLURM_ARRAY_TASK_ID}+1978))




