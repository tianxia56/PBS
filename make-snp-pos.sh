#!/bin/bash

# Base URL for downloading chromosome files
#base_url="https://ftp.ncbi.nih.gov/snp/pre_build152/organisms/human_9606_b150_GRCh37p13/chr_rpts"
base_url="https://ftp.ncbi.nih.gov/snp/pre_build152/organisms/human_9606_b150_GRCh38p7/chr_rpts"

# Create a temporary file to store the merged data
temp_file="merged_data.tsv"

# Loop through chromosomes 1 to 22
for chr in {1..22}; do
  # Construct the file name and URL
  file_name="chr_${chr}.txt.gz"
  url="${base_url}/${file_name}"

  # Download the file
  echo "Downloading ${file_name}..."
  wget "$url" -O "$file_name"

  # Unzip the file
  echo "Processing ${file_name}..."
  gunzip "$file_name"

  # Extract columns 1, 7, and 12, append "rs" to the first column, and append to the temporary file
  awk -F'\t' '{print "rs"$1, $7, $12}' OFS='\t' "chr_${chr}.txt" >> "$temp_file"
done

# Compress the merged data into a gzipped file
#gzip -c "$temp_file" > "build37.snp.pos.tsv.gz"
gzip -c "$temp_file" > "build38.snp.pos.tsv.gz"

# Remove the temporary file
rm "$temp_file"

#zcat build37.snp.pos.tsv.gz | tail -n +8 | gzip > build37.snp.pos.cleaned.tsv.gz
#zcat build38.snp.pos.tsv.gz | tail -n +8 | gzip > build38.snp.pos.cleaned.tsv.gz

#echo "Merged data has been saved to build37.snp.pos.tsv.gz"
echo "Merged data has been saved to build38.snp.pos.tsv.gz"
