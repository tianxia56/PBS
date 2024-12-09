#!/bin/bash
#SBATCH --partition=day
#SBATCH --time=23:00:00
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=1
#SBATCH --mem-per-cpu=102400
bash make-max-afr-pbs.sh
