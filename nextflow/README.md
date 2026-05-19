# Nextflow Wrapper

This directory contains thin wrapper scripts around `nf-core/rnaseq`.

- `run_nfcore_rnaseq.sh`: run directly from the current shell
- `submit_nfcore_rnaseq.sh`: submit the wrapper itself through Slurm when `sbatch` is available
- `nextflow.config`: minimal executor-side defaults for Slurm and Singularity

The wrapper is intentionally small and defers pipeline semantics to the upstream `nf-core/rnaseq` project.
