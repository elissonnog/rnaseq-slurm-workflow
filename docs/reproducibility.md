# Reproducibility Notes

Record the inputs and runtime configuration used for each analysis so that a
generated experiment directory can be interpreted later.

## Recommended Tracking Files

- `config/reference_manifest.tsv.example`: record the exact FASTA, GTF, and STAR index assets used for a run
- `config/software_versions.tsv.example`: record tool versions or module names
- `pipeline.env`: keep the exact run configuration alongside each generated experiment directory

Keep the generated `samples.txt`, `pipeline.env`, reference manifest, software
versions, scheduler logs, and repository commit SHA with each run. Scheduler
resources, strandedness, count unit, index parameters, and QC thresholds are
project-specific choices and should be documented with the analysis.
