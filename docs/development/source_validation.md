# Source Validation

This staging repo was assembled from the following local RNA-seq source files:

## Canonical Workflow Sources

- `mycodes/bulk/STAR_index copy.sh`
- `mycodes/bulk/fastqc_pretrim copy.sh`
- `mycodes/bulk/trim_galore_fastqc copy.sh`
- `mycodes/bulk/star_alignReads copy.sh`
- `mycodes/bulk/samtools_index copy.sh`
- `mycodes/bulk/featureCounts copy.txt`
- `mycodes/bulk/multiqc copy.sh`

## Secondary Slurm References

- `mycodes/bulkEric/fastq.sh`
- `mycodes/bulkEric/trimmer.sh`
- `mycodes/bulkEric/starindex.sh`
- `mycodes/bulkEric/starReads.sh`

## Downstream Analysis Companion

- `mycodes/bulk/RNA_bulk.Rmd`
- `mycodes/bulk/EL_RNA_bulk copy.Rmd`

## Mapping From Source to Staged Workflow

- `00_star_index.sh`: based primarily on `STAR_index copy.sh`, with generic FASTA and GTF inputs
- `01_fastqc_raw.sh`: based on the raw-read FastQC steps from `fastqc_pretrim copy.sh` and `bulkEric/fastq.sh`
- `02_trim_galore.sh`: based on the paired-end Trim Galore invocation in `trim_galore_fastqc copy.sh` and `bulkEric/trimmer.sh`
- `03_star_align.sh`: based on `star_alignReads copy.sh`, preserving trimmed-read alignment and `--quantMode GeneCounts`
- `04_samtools_index.sh`: based on `samtools_index copy.sh`
- `05_featurecounts.sh`: reconstructed from `featureCounts copy.txt` because the paired shell script is not a counting step
- `06_multiqc.sh`: based on `multiqc copy.sh`
- `scripts/star_gene_counts_to_matrix.R`: derived from the `star2matrix()` helper in the downstream notebooks
