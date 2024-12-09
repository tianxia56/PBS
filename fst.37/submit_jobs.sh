#!/bin/bash

# Submit each job with the corresponding Python script
sbatch pbs_template.sh pbs.afr.py
sbatch pbs_template.sh pbs.amr.py
sbatch pbs_template.sh pbs.eas.py
sbatch pbs_template.sh pbs.sas.py
sbatch pbs_template.sh pbs.eur.py

#Steps to Execute
#Create the SLURM script template: Save the pbs_template.sh script.
#Create the submission script: Save the submit_jobs.sh script.
#Create the cleanup script: Save the cleanup.sh script.
#Submit the jobs: Run the submit_jobs.sh script to submit all the tasks.
#bash submit_jobs.sh

#Run the cleanup script: After all jobs have completed, run the cleanup.sh script to remove the intermediate files.
#bash cleanup.sh
