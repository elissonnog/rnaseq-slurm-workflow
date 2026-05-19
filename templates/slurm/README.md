# Slurm Workflow Templates

This directory contains the core numbered RNA-seq workflow steps that are rendered into experiment-specific job scripts by `scripts/generate_experiment.pl`.

Core processing steps:

0. `00_star_index.sh` - STAR genome generation from FASTA and GTF
1. `01_fastqc_raw.sh` - raw FASTQ quality control
2. `02_trim_galore.sh` - paired-end adapter trimming with FastQC
3. `03_star_align.sh` - STAR two-pass alignment with `ReadsPerGene.out.tab` output
4. `04_samtools_index.sh` - BAM indexing
5. `05_featurecounts.sh` - gene-level counting across aligned BAM files
6. `06_multiqc.sh` - aggregate QC reporting

Shared helper:

- `common.sh` - configuration loading, module loading, and file guards
