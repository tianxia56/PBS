## Replication of 'A global reference for human genetic variation' in GRCh38

![PBS distribution](https://media.springernature.com/full/springer-static/image/art%3A10.1038%2Fnature15393/MediaObjects/41586_2015_Article_BFnature15393_Fig3_HTML.jpg?as=webp)

## Known Flipping and Position Shifts in GRCh37

- ScienceDirect Article(https://www.sciencedirect.com/science/article/pii/S2666247722000768)

## 2019 Version Release Assembly by GRCh38

- 1000 Genomes Project Release 20190312 (ftp://ftp.1000genomes.ebi.ac.uk/vol1/ftp/data_collections/1000_genomes_project/release/20190312_biallelic_SNV_and_INDEL)

## GRCh38 exon annotations

- GENECODE GTF (https://www.gencodegenes.org/human/release_38.html)
- extract columns to be:
  
`zcat gencode.v37lift37.annotation.gtf.gz | awk -F'\t' '$3 == "exon" {split($9, a, "; "); for (i in a) if (a[i] ~ /gene_name/) {split(a[i], b, "\""); gene_name = b[2]} print substr($1, 4) "\t" $3 "\t" $4 "\t" $5 "\t" gene_name}' OFS='\t' > ../fst/grch37.exon.region`

`$ head grch38.exon.region`
`1       exon    11869   12227   DDX11L1`

## Workflow
requirements: vcftools, bedtools

1. Make pairwise Fst within super populations `pairwise_fst.sh`,`check_missing_fst.sh`

2. Make one vs. all other populations out side of its own super population `one_outgroup_fst.sh`

3. Compute PBS `make_pbs_per_suppop.py`, `pbs_batch.sh`

4. Normalize PBS and rowbind in the same population of interest, only keep the maximum PBS_normed among duplications `make-max-supop-pbs.sh`, `all_max_pbs.sh`

5. Plot `plot_pbs.py` input < superpop id >, < palette color tag >, < popid.gene.tag >, < y axis limit (80) >

## genomewide GRCh37 and GRCH38 rsid mapping

https://ftp.ncbi.nlm.nih.gov/snp/organisms/

`make-snp-pos.sh`

## More about PBS
The Precision and Power of Population Branch Statistics in Identifying the Genomic Signatures of Local Adaptation
Max Shpak, Kadee N. Lawrence, John E. Pool doi: https://doi.org/10.1101/2024.05.14.594139

![PBS performance](https://www.biorxiv.org/content/biorxiv/early/2024/05/17/2024.05.14.594139/F1.large.jpg?width=800&height=600&carousel=1)


