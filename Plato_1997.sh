#!/bin/bash
#SBATCH --job-name=PG_1997
#SBATCH --time=0-3:00:00
#SBATCH --mem=5G
module load python/3.7.4
srun python -u main_CAI_update.py 1997
