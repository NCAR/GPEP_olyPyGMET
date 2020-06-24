#!/bin/bash
#SBATCH --job-name=tmean3
#SBATCH --time=0-6:00:00
#SBATCH --mem=20G
module load python/3.7.4
srun python -u temprun.py tmean 3
