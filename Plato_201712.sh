#!/bin/bash
#SBATCH --job-name=PG_201712
#SBATCH --time=0-12:00:00
#SBATCH --mem=20G
module load python/3.7.4
srun python -u main_CAI_update.py 201712
