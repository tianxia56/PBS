#!/bin/bash

# Define the panel file
panel_file="../integrated_call_samples_v3.20130502.ALL.panel"

# Extract unique populations
populations=$(cut -f2 $panel_file | tail -n +2 | sort | uniq)

# Define the super populations
super_pops=$(cut -f3 $panel_file | tail -n +2 | sort | uniq)

# Check for missing FST files
missing_files=0

for super_pop in $super_pops
do
  # Get populations under the same super population
  pops=$(grep -w $super_pop $panel_file | cut -f2 | sort | uniq)

  for pop_a in $pops
  do
    for pop_b in $pops
    do
      if [ "$pop_a" != "$pop_b" ]; then
        for chr in {1..22}
        do
          fst_file=~/palmer_scratch/fst/$super_pop/${pop_a}.${pop_b}.chr${chr}.weir.fst
          if [ ! -f "$fst_file" ]; then
            echo "Missing FST file: $fst_file"
            missing_files=$((missing_files + 1))
          fi
        done
      fi
    done
  done
done

if [ $missing_files -eq 0 ]; then
  echo "All FST files have been computed."
else
  echo "Total missing FST files: $missing_files"
fi
