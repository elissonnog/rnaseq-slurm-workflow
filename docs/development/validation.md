# Local Validation

Validation date: May 19, 2026

## Completed Checks

- `bash -n` passed for:
  - `bin/rnaseq-init`
  - `bin/rnaseq-submit`
  - all files in `templates/slurm/`
  - `nextflow/run_nfcore_rnaseq.sh`
  - `nextflow/submit_nfcore_rnaseq.sh`
- `perl -c` passed for:
  - `scripts/generate_experiment.pl`
  - `scripts/submit_chain.pl`
- `Rscript --vanilla -e "parse(...)"` passed for:
  - `scripts/star_gene_counts_to_matrix.R`
- `tests/smoke/run_slurm_smoke.sh` passed:
  - rendered a demo experiment bundle from `examples/slurm-dry-run/samples.txt`
  - generated numbered steps `00` through `06`
  - dry-ran the Slurm dependency chain successfully

## Tools Present On The Local Mac

- `samtools`
- `Rscript`
- `perl`

## Tools Not Present During Validation

- `fastqc`
- `trim_galore`
- `STAR`
- `featureCounts`
- `multiqc`
- `nextflow`

## Validation Scope

The current validation confirms repository integrity, renderability, and submission ordering. It does not confirm end-to-end RNA-seq execution, reference compatibility, or biological reproducibility, because the external RNA-seq toolchain and real input data were not available locally.
