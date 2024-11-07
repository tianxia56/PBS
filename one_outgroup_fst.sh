#!/bin/bash

# Define the panel file
panel_file="../integrated_call_samples_v3.20130502.ALL.panel"

# Create a directory to store the population files
mkdir -p pop_files

# Extract unique populations
populations=$(cut -f2 $panel_file | tail -n +2 | sort | uniq)

# Generate .txt files for each population
for pop in $populations
do
  grep -w $pop $panel_file | cut -f1 > pop_files/${pop}.txt
done

# Define the super populations
super_pops=$(cut -f3 $panel_file | tail -n +2 | sort | uniq)

# Create a directory to store merged population files
mkdir -p merged_pop_files

# Generate merged population files for each super population
for super_pop in $super_pops
do
  grep -w $super_pop $panel_file | cut -f1 > merged_pop_files/${super_pop}.txt
done

# Run VCFtools for each population against all merged populations outside its super population
for pop in $populations
do
  # Get the super population of the current population
  super_pop=$(grep -w $pop $panel_file | cut -f3 | uniq)

  # Create a directory for the results
  mkdir -p ~/palmer_scratch/fst/${pop}_vs_others

  # Merge all populations outside the current super population
  merged_pops_file=merged_pop_files/merged_others_${pop}.txt
  grep -v -w $super_pop $panel_file | cut -f1 > $merged_pops_file

  # Run VCFtools for each chromosome
  for chr in {1..22}
  do
    vcftools --gzvcf ALL.chr${chr}.shapeit2_integrated_snvindels_v2a_27022019.GRCh38.phased.v4.2.vcf.gz \
             --weir-fst-pop pop_files/${pop}.txt \
             --weir-fst-pop $merged_pops_file \
             --out ~/palmer_scratch/fst/${pop}_vs_others/${pop}.merged_others.chr${chr}
  done
done
