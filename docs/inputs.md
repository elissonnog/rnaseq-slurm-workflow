# Inputs

## Slurm Workflow Inputs

Required files:

- `samples.txt`: one sample ID per line; blank lines and comments are removed in the generated execution manifest
- paired FASTQ files named as `${sample}${READ1_SUFFIX}` and `${sample}${READ2_SUFFIX}`
- reference genome FASTA
- reference annotation GTF

Important behavior:

- the sample manifest should contain the exact sample stems used in FASTQ filenames
- sample IDs must be unique and match `[A-Za-z0-9][A-Za-z0-9._-]*`; whitespace, path separators, and shell metacharacters are rejected
- the template workflow assumes a consistent paired-end FASTQ naming convention across the run
- trimmed FASTQ suffixes default to the `trim_galore` paired-end naming pattern
- feature counting uses only BAMs named from the normalized manifest, in manifest order
- `FEATURECOUNTS_COUNT_UNIT=read` preserves the historical paired-end `-p` behavior; `fragment` additionally passes `--countReadPairs`. Choose deliberately for the installed Subread version and analysis plan
- `STAR_INDEX_MODE=build` creates the index from FASTA/GTF; `use_existing` validates and uses `STAR_INDEX_DIR` without rebuilding
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
