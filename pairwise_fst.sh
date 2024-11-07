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

# Define the super population
super_pop="AFR AMR EUR EAS SAS"

# Get populations under the same super population
pops=$(grep -w $super_pop $panel_file | cut -f2 | sort | uniq)

# Create a directory for the super population
mkdir -p ~/palmer_scratch/fst/$super_pop

# Chromosomes to analyze
chromosomes=(1:22)

# Pairwise comparison for specified chromosomes
for i in "${chromosomes[@]}"
do
  for pop_a in $pops
  do
    for pop_b in $pops
    do
      if [ "$pop_a" != "$pop_b" ]; then
        vcftools --gzvcf ALL.chr${i}.shapeit2_integrated_snvindels_v2a_27022019.GRCh38.phased.v4.2.vcf.gz \
                 --weir-fst-pop pop_files/${pop_a}.txt \
                 --weir-fst-pop pop_files/${pop_b}.txt \
                 --out ~/palmer_scratch/fst/$super_pop/${pop_a}.${pop_b}.chr${i}
      fi
    done
  done
done
