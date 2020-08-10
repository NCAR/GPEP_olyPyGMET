#!/bin/bash
#SBATCH --job-name=reliadiscri
#SBATCH --account=rpp-kshook
#SBATCH --time=0-2:00:00
#SBATCH --mem=10G

module load python/3.7.4
source ~/ENV/bin/activate
srun python -u rel_dis_datapre.py