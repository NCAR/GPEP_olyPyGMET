#!/bin/bash
#SBATCH --job-name=bssrpss
#SBATCH --account=rpp-kshook
#SBATCH --time=0-20:00:00
#SBATCH --mem=100G

module load python/3.7.4
source ~/ENV/bin/activate
srun python -u data_pre.py