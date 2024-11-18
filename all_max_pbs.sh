#!/bin/bash
#SBATCH --partition=day
#SBATCH --time=23:00:00
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=1
#SBATCH --mem-per-cpu=102400
#SBATCH --exclusive

sbatch --job-name=max-afr bash make-max-afr-pbs.sh
sbatch --job-name=max-amr bash make-max-amr-pbs.sh
sbatch --job-name=max-eas bash make-max-eas-pbs.sh
sbatch --job-name=max-eur bash make-max-eur-pbs.sh
sbatch --job-name=max-sas bash make-max-sas-pbs.sh
