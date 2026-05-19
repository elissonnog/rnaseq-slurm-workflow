# Quick Start

This repository supports two execution modes:

1. a Slurm-template workflow derived from the original local RNA-seq scripts
2. a generic wrapper around `nf-core/rnaseq`

## Option 1: Slurm Workflow

Generate an experiment directory:

```bash
bin/rnaseq-init \
  --project-dir /path/to/project \
  --sample-file examples/slurm-dry-run/samples.txt \
  --experiment demo_run
```

Then edit:

- `demo_run/pipeline.env`

Dry-run the submission chain:

```bash
bin/rnaseq-submit --experiment-dir demo_run --dry-run
```

Submit the workflow:

```bash
bin/rnaseq-submit --experiment-dir demo_run
```

## Option 2: nf-core/rnaseq

Copy and edit:

- `config/nextflow.env.example`
- `examples/nextflow/samplesheet.csv`

Run directly:

```bash
bash nextflow/run_nfcore_rnaseq.sh config/nextflow.env
```

Or submit through Slurm:

```bash
bash nextflow/submit_nfcore_rnaseq.sh config/nextflow.env
```
