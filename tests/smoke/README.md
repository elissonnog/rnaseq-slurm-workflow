# Smoke Test

The Slurm smoke test validates syntax, normalized sample-manifest rules, generated-script relocation, manifest-ordered featureCounts arguments, Nextflow/Slurm command construction with fake executables, and dependency rendering without FASTQ inputs or external bioinformatics execution.

`run_star_counts_fixture.sh` separately requires R and edgeR and compares a two-sample synthetic STAR fixture with an exact expected genes-by-samples TSV.
