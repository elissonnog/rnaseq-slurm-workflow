# Bulk RNA-seq workflow for Slurm

A paired-end bulk RNA-seq workflow for HPC systems using Slurm. The numbered
steps run raw-read QC, Trim Galore, STAR indexing and alignment, BAM indexing,
featureCounts, and MultiQC. An optional wrapper for `nf-core/rnaseq` is also
included.

## Requirements

- Bash, Perl, and Slurm
- FastQC, Trim Galore, STAR, SAMtools, featureCounts, and MultiQC available on
  `PATH` or through the modules configured in `pipeline.env`
- paired FASTQ files
- reference FASTA and GTF files, or an existing compatible STAR index

Sample IDs are supplied one per line and must match the FASTQ filename stems.

## Run the Slurm workflow

Generate an experiment directory:

```bash
bin/rnaseq-init \
  --project-dir /path/to/analysis \
  --sample-file examples/slurm-dry-run/samples.txt \
  --experiment rnaseq_run
```

Edit `rnaseq_run/pipeline.env` with the FASTQ, reference, module, and resource
settings for your cluster. Inspect the jobs without submitting them:

```bash
bin/rnaseq-submit --experiment-dir rnaseq_run --dry-run
```

Submit the dependency chain:

```bash
bin/rnaseq-submit --experiment-dir rnaseq_run
```

The main outputs are written under `--project-dir`:

- `fastqc_raw/` and `multiqc/` for QC reports
- `trim_output/` for trimmed reads
- `star_align/` for BAM files, STAR logs, and gene-count tables
- `counts/featurecounts.txt` for gene-level counts

Detailed input and output conventions are in
[docs/inputs.md](docs/inputs.md) and [docs/outputs.md](docs/outputs.md).

## Optional nf-core/rnaseq wrapper

```bash
cp config/nextflow.env.example config/nextflow.env
# Edit config/nextflow.env and the nf-core samplesheet first.
bash nextflow/run_nfcore_rnaseq.sh config/nextflow.env
```

The custom Slurm path and the nf-core wrapper are separate execution options.
The dry-run example checks script generation and job ordering; it does not
replace an end-to-end run with appropriate reference assets and sequencing
data. An existing STAR index is checked for directory presence, so its genome
build and annotation compatibility must be confirmed by the user.

## Contribution

Developed during my postdoctoral research at Van Andel Institute.

## References

- [STAR](https://github.com/alexdobin/STAR)
- [SAMtools](https://www.htslib.org/)
- [featureCounts](https://subread.sourceforge.net/)
- [MultiQC](https://multiqc.info/)
- [nf-core/rnaseq](https://github.com/nf-core/rnaseq)
