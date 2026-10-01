# Reproducibility Notes

This staged repository is a cleaned workflow layer derived from the local bulk RNA-seq scripts and notebooks. It preserves the main execution logic while replacing project-specific paths and scheduler details with configurable inputs.

## Recommended Tracking Files

- `config/reference_manifest.tsv.example`: record the exact FASTA, GTF, and STAR index assets used for a run
- `config/software_versions.tsv.example`: record tool versions or module names
- `pipeline.env`: keep the exact run configuration alongside each generated experiment directory

## Source-Based Corrections Applied

The staged workflow keeps the source logic but fixes issues that would block generic reuse:

- `featureCounts` was reconstructed from the command recorded in `mycodes/bulk/featureCounts copy.txt`, because `mycodes/bulk/featureCounts copy.sh` duplicates BAM indexing instead of counting
- STAR alignment uses trimmed reads, matching the canonical `mycodes/bulk/star_alignReads copy.sh` path rather than the raw-read `bulkEric/starReads.sh` variant
- STAR genome generation requires separate FASTA and GTF inputs; the erroneous `--sjdbGTFfile` FASTA path present in `bulkEric/starindex.sh` is not propagated

## Validation Scope

Local validation for this repository is structural:

- shell syntax
- Perl syntax
- optional R utility parse validation
- experiment generation
- normalized sample-manifest validation
- Slurm-spooled script relocation with fake tool execution
- manifest-ordered featureCounts argument construction
- Nextflow and Slurm wrapper command construction with fake executables
- Slurm submission-order dry run
- exact two-sample synthetic STAR count-matrix comparison when R and edgeR are available

End-to-end biological execution still requires real FASTQ inputs, reference assets, and the external command-line tools listed in `README.md`.

Scheduler resources and tool threads are separate settings. The generated scripts reject configured thread counts above `SLURM_CPUS_PER_TASK` when that Slurm variable is present, but memory, wall time, queue/partition, index parameters, strandedness, count unit, and QC thresholds remain dataset- and site-specific scientific/operational choices rather than validated universal defaults.
