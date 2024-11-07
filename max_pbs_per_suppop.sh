#!/bin/bash

# Define the folder to process
folder="PBS.AFR"

# Path to the exon region file
exon_file="grch38.exon.region"

# Function to standardize PBS values
standardize_pbs() {
  input_file=$1
  output_file=$2

  awk '
  BEGIN {
    sum = 0;
    sumsq = 0;
    count = 0;
  }
  NR > 1 {
    sum += $3;
    sumsq += ($3)^2;
    count++;
  }
  END {
    mean = sum / count;
    sd = sqrt(sumsq / count - mean^2);
    if (sd == 0) sd = 1;  # Prevent division by zero
    print mean, sd;
  }
  ' "$input_file" > "temp_stats.txt"

  mean=$(awk '{print $1}' "temp_stats.txt")
  sd=$(awk '{print $2}' "temp_stats.txt")

  awk -v mean="$mean" -v sd="$sd" '
  BEGIN { OFS = "\t"; }
  NR == 1 { print $1, $2, "PBS", "PBS_norm"; next; }
  {
    PBS_norm = ($3 - mean) / sd;
    print $1, $2, $3, PBS_norm;
  }
  ' "$input_file" > "$output_file"
}

echo "Processing folder: $folder"
cd "$folder" || exit

# Ensure CHROM column is character and coordinates are integers
awk '{ $1 = "chr" $1; $3 = int($3); $4 = int($4); print $1, $3, $4, $5 }' OFS="\t" "../$exon_file" > "temp_exon_file.txt"

# Debugging output to check the contents of temp_exon_file.txt
echo "Contents of temp_exon_file.txt:"
head "temp_exon_file.txt"

# Get list of all .PBS.txt files in the current directory
files=$(ls *.PBS.txt)

declare -A pop1_outputs

for file in $files; do
  pop1=$(basename "$file" | cut -d'.' -f1)
  pop2=$(basename "$file" | cut -d'.' -f2)

  # Standardize PBS values
  standardized_file="${file%.PBS.txt}.PBS.normed.txt"
  standardize_pbs "$file" "$standardized_file"

  # Prepare PBS data for bedtools
  awk 'NR > 1 {print "chr"$1, $2, $2, $3, $4}' OFS="\t" "$standardized_file" > "temp_pbs_file.bed"

  # Use bedtools to intersect PBS data with exon regions
  bedtools intersect -a "temp_pbs_file.bed" -b "temp_exon_file.txt" -wa -wb > "temp_intersected_file.txt"

  # Format the output file and remove duplicates
  awk 'BEGIN {OFS="\t"; print "CHROM", "POS", "PBS", "PBS_norm", "GENE"} !seen[$1, $2]++ {print $1, $2, $4, $5, $9}' "temp_intersected_file.txt" > "${file%.PBS.txt}.PBS.normed_exon.txt"

  # Append to pop1_outputs
  if [ -z "${pop1_outputs[$pop1]}" ]; then
    pop1_outputs[$pop1]="${file%.PBS.txt}.PBS.normed_exon.txt"
  else
    cat "${file%.PBS.txt}.PBS.normed_exon.txt" >> "${pop1_outputs[$pop1]}"
  fi

  # Remove intermediate files for the current file
  rm "$standardized_file" "${file%.PBS.txt}.PBS.normed_exon.txt"
done

# Keep only the maximum PBS_norm for each CHROM and POS within the same folder
for pop1 in "${!pop1_outputs[@]}"; do
  awk 'BEGIN {OFS="\t"} NR==1 {print; next} {if ($1 OFS $2 in max_pbs_norm) {if ($4 > max_pbs_norm[$1 OFS $2]) {max_pbs_norm[$1 OFS $2]=$4; line[$1 OFS $2]=$0}} else {max_pbs_norm[$1 OFS $2]=$4; line[$1 OFS $2]=$0}} END {for (pos in line) print line[pos]}' "${pop1_outputs[$pop1]}" > "${pop1}.combined.PBS.normed_exon.txt"
  echo "Created file: ${pop1}.combined.PBS.normed_exon.txt"

  # Remove intermediate combined files for the current pop1
  rm "${pop1_outputs[$pop1]}"
done

# Remove intermediate files for the entire process within the folder
rm "temp_exon_file.txt" "temp_stats.txt" "temp_pbs_file.bed" "temp_intersected_file.txt"

cd ..

echo "Processing complete. Files have been saved in their respective folders."

