## Replication of 'A global reference for human genetic variation' in GRCh38

![PBS distribution](https://media.springernature.com/full/springer-static/image/art%3A10.1038%2Fnature15393/MediaObjects/41586_2015_Article_BFnature15393_Fig3_HTML.jpg?as=webp)

## Known Flipping and Position Shifts in GRCh37

- ScienceDirect Article(https://www.sciencedirect.com/science/article/pii/S2666247722000768)

## 2019 Version Release Assembly by GRCh38

- 1000 Genomes Project Release 20190312 (ftp://ftp.1000genomes.ebi.ac.uk/vol1/ftp/data_collections/1000_genomes_project/release/20190312_biallelic_SNV_and_INDEL)

## Workflow
1. Make pairwise Fst within super populations `pairwise_fst.sh`,`check_missing_fst.sh`

2. Make one vs. all other populations out side of its own super population `one_outgroup_fst.sh`

3. Compute PBS `make_pbs_per_suppop.py`, `pbs_batch.sh`

4. Normalize PBS and rowbind in the same population of interest, only keep the maximum PBS_normed among duplications `max_pbs_per_suppop.sh`, `all_max_pbs.sh`

5. Plot `plot_pbs.py` input <superpop id>, <palette color tag>, <popid.gene.tag>, <y axis limit (80)>
