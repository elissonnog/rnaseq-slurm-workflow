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
- Slurm submission-order dry run

End-to-end biological execution still requires real FASTQ inputs, reference assets, and the external command-line tools listed in `README.md`.
