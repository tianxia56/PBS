#!/bin/bash
#SBATCH --partition=week
#SBATCH --time=7-00:00:00
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=1
#SBATCH --mem-per-cpu=102400



python pbs.afr.py
python pbs.amr.py
python pbs.eas.py
python pbs.sas.py
python pbs.eur.py

rm ./PBS.AFR/*.chr*
rm ./PBS.AMR/*.chr*
rm ./PBS.EAS/*.chr*
rm ./PBS.SAS/*.chr*
rm ./PBS.EUR/*.chr*
