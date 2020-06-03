#!/bin/bash
#SBATCH --job-name=prcp3
#SBATCH --time=0-2:00:00
#SBATCH --mem=15G
module load python/3.7.4
srun python -u observation_reanalysis_merge.py 1979 2018 prcp 3
