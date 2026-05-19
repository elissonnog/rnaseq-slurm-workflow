# Inputs

## Slurm Workflow Inputs

Required files:

- `samples.txt`: one sample ID per line
- paired FASTQ files named as `${sample}${READ1_SUFFIX}` and `${sample}${READ2_SUFFIX}`
- reference genome FASTA
- reference annotation GTF

Important behavior:

- the sample manifest should contain the exact sample stems used in FASTQ filenames
- the template workflow assumes a consistent paired-end FASTQ naming convention across the run
- trimmed FASTQ suffixes default to the `trim_galore` paired-end naming pattern
- feature counting uses the strandedness code set in `FEATURECOUNTS_STRAND`
- the STAR-to-matrix utility expects STAR `ReadsPerGene.out.tab` outputs in the alignment directory

If a study requires per-sample FASTQ paths, mixed naming patterns, or richer sample metadata, the `nf-core/rnaseq` wrapper path is the safer execution mode.

## Nextflow Wrapper Inputs

Required files:

- `config/nextflow.env`
- `samplesheet.csv` following the `nf-core/rnaseq` schema

The example samplesheet uses the current `sample,fastq_1,fastq_2,strandedness,seq_platform` pattern documented by `nf-core/rnaseq`.

See:

- `config/nfcore_samplesheet.csv.example`
- `examples/nextflow/samplesheet.csv`
