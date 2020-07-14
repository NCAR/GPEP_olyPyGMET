#!/bin/bash
#SBATCH --job-name=extdata
#SBATCH --account=rpp-kshook
#SBATCH --time=0-10:00:00
#SBATCH --mem=20G

module load python/3.7.4
source ~/ENV/bin/activate
srun python -u main_extract.py
