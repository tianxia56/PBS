import pandas as pd
import numpy as np
from functools import reduce
import os

# Function to read fst files and return a DataFrame
def read_fst(file_path):
    return pd.read_csv(file_path, sep='\t')

# Function to compute PBS
def compute_pbs(fst1, fst2, fst3):
    return (-np.log(1 - fst1) - np.log(1 - fst2) + np.log(1 - fst3)) / 2

# Define the super population
# do one at a time, and bash to do batch
super_pop = 'EUR'

# Create a directory to save the PBS files
pbs_dir = os.path.expanduser(f'~/palmer_scratch/fst/PBS.{super_pop}')
os.makedirs(pbs_dir, exist_ok=True)

# Get all .weir.fst files for the super population
fst_dir = os.path.expanduser(f'~/palmer_scratch/fst/{super_pop}')
fst_files = [f for f in os.listdir(fst_dir) if f.endswith('.weir.fst')]

# Iterate over each chromosome from 1 to 22
for chr_num in range(1, 23):
    print(f"Processing chromosome {chr_num}...")
    processed_pairs = set()
    # Iterate over each pairwise population file
    for file in fst_files:
        parts = file.split('.')
        if len(parts) < 3:
            continue
        pop1, pop2 = parts[0], parts[1]
        pair = (pop1, pop2)

        # Check if this pair has already been processed for this chromosome
        if pair in processed_pairs:
            continue

        # Define file paths for the current population pair and chromosome
        eur_file = os.path.join(fst_dir, f'{pop1}.{pop2}.chr{chr_num}.weir.fst')
        outgroup_pop2_file = os.path.join(f'./outgroup/{pop2}.merged_others.chr{chr_num}.weir.fst')
        outgroup_pop1_file = os.path.join(f'./outgroup/{pop1}.merged_others.chr{chr_num}.weir.fst')

        # Check if the files exist before proceeding
        if not (os.path.exists(eur_file) and os.path.exists(outgroup_pop2_file) and os.path.exists(outgroup_pop1_file)):
            print(f"One or more files for {pop1} vs {pop2} on chromosome {chr_num} are missing. Skipping...")
            continue

        # Read the fst files
        eur_df = read_fst(eur_file)
        outgroup_pop2_df = read_fst(outgroup_pop2_file)
        outgroup_pop1_df = read_fst(outgroup_pop1_file)

        # Rename the third column to match the population pair
        eur_df.rename(columns={'WEIR_AND_COCKERHAM_FST': f'{pop1}-{pop2}'}, inplace=True)
        outgroup_pop2_df.rename(columns={'WEIR_AND_COCKERHAM_FST': f'{pop2}-merged_others'}, inplace=True)
        outgroup_pop1_df.rename(columns={'WEIR_AND_COCKERHAM_FST': f'{pop1}-merged_others'}, inplace=True)

        # Remove duplicates based on POS column
        eur_df = eur_df.drop_duplicates(subset='POS')
        outgroup_pop2_df = outgroup_pop2_df.drop_duplicates(subset='POS')
        outgroup_pop1_df = outgroup_pop1_df.drop_duplicates(subset='POS')

        # Perform inner join on CHROM and POS columns
        merged_df = reduce(lambda x, y: pd.merge(x, y, on=['CHROM', 'POS']), [eur_df, outgroup_pop2_df, outgroup_pop1_df])

        # Remove rows containing NaN values
        merged_df.dropna(inplace=True)

        # Compute PBS
        merged_df['PBS'] = compute_pbs(merged_df[f'{pop1}-{pop2}'], 
                                       merged_df[f'{pop1}-merged_others'], 
                                       merged_df[f'{pop2}-merged_others'])

        # Select relevant columns (excluding FST columns)
        pbs_df = merged_df[['CHROM', 'POS', 'PBS']]

        # Define output file path without compression
        output_file = os.path.join(pbs_dir, f'{pop1}.{pop2}.PBS.chr{chr_num}.txt')

        # Save the PBS dataframe to a text file without compression
        pbs_df.to_csv(output_file, sep='\t', index=False)

        print(f"PBS computation and file saving completed for {pop1} vs {pop2} on chromosome {chr_num}.")

        # Mark this pair as processed for this chromosome
        processed_pairs.add(pair)

# Combine PBS files for each population pair across all chromosomes into a single text file without removing per-chromosome files
for file in fst_files:
    parts = file.split('.')
    if len(parts) < 3:
        continue
    pop1, pop2 = parts[0], parts[1]
    combined_pbs_file = os.path.join(pbs_dir, f'{pop1}.{pop2}.PBS.txt')
    
    with open(combined_pbs_file, 'w') as combined_out:
        header_written = False  # Flag to write header only once
        for chr_num in range(1, 23):
            chr_file = os.path.join(pbs_dir, f'{pop1}.{pop2}.PBS.chr{chr_num}.txt')
            if os.path.exists(chr_file):
                with open(chr_file, 'r') as f_in:
                    lines = f_in.readlines()
                    if not header_written:
                        combined_out.write(lines[0])  # Write header from the first file only
                        header_written = True
                    combined_out.writelines(lines[1:])  # Write data lines
    
    # Check if the combined file is greater than 0 bytes
    if os.path.getsize(combined_pbs_file) > 0:
        print(f"Combined PBS file created: {combined_pbs_file}")
    else:
        print(f"Combined PBS file is empty: {combined_pbs_file}")

print("All PBS computations completed and combined into single text files per population pair.")

