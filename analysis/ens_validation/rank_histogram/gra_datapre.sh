#!/bin/bash
#SBATCH --job-name=datapre
#SBATCH --account=rpp-kshook
#SBATCH --time=0-0:30:00
#SBATCH --mem=20G

module load python/3.7.4
source ~/ENV/bin/activate
srun python -u data_pre.py