#!/bin/bash
#SBATCH --job-name=prcp2006
#SBATCH --time=0-3:00:00
#SBATCH --mem=20G
module load python/3.7.4
srun python -u s6_rea_corrmerge_No.py prcp BMA zz 2006 2006
