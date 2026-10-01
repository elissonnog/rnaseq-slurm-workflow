# Private Publication Review

Base snapshot: `88c4f4fd68a5011a9d32b9d991b211f619e2e54a`

Review date: October 1, 2026

## Prepared for Review

- Added an explicit scientific-purpose and contribution/provenance boundary.
- Marked all demonstration sample identifiers as synthetic.
- Added a deterministic representative Slurm dependency plan and made the smoke test compare against it.
- Added lightweight GitHub Actions CI for repository orchestration.
- Added a candidate pinned command-line environment matching the historically documented tool versions.

## Checks on This Mac

- The downloaded archive corresponds to the single GitHub commit above.
- `bash -n` passed for both entrypoints, every Slurm template, and both Nextflow wrapper scripts.
- `perl -c` passed for `generate_experiment.pl` and `submit_chain.pl`.
- `tests/smoke/run_slurm_smoke.sh` passed, including generated-script parsing, manifest preservation, and exact normalized dependency-plan comparison.
- Filename/content scan found no credential-pattern files, private keys, institutional email addresses, project identifiers, or absolute `/Users`, `/home`, `/Volumes`, or `/varidata` paths.
- The user installed and opened the normal R.app distribution. R 4.6.1 reported `R.home()` as `/Library/Frameworks/R.framework/Resources`, and `/usr/local/bin/Rscript` resolved to that framework. No extracted `review-tools/R.framework` runtime or package library was used for the results below.
- With official binaries in the clean `review-tools/normal-R-library/`, `scripts/star_gene_counts_to_matrix.R` parsed and a two-sample synthetic STAR fixture byte-matched the expected TSV using `edgeR` 4.10.5.
- The repository smoke workflow passed on the private `review/portfolio-prep-2026-10-01` branch on October 1, 2026.
- macOS command-line signature checks previously reported `invalid signature` / an internal code-signing error for R.app. The user-opened app showed no warning and functioned normally, but this discrepancy remains unresolved and must not be described as renewed signature verification.
- The Conda environment was not solved because Conda is unavailable.
- No alignment, feature counting, HPC submission, real-data analysis, or nf-core execution was attempted.

## Rights Gate

The user confirmed authorship of the workflow scripts on October 1, 2026. No license was added. Institutional release permission and a license choice remain unresolved; authorship confirmation alone does not establish the right to redistribute institutional references, adapted components, or associated data.

The following contribution wording requires author confirmation:

> Applied bulk RNA-seq workflow logic was adapted into a parameterized Slurm pipeline. Portable entrypoints, dependency-safe submission, dry-run tests, synthetic examples, and documentation were produced during assisted portfolio curation.

## Publication Gate

1. Resolve or independently review the macOS signature-check discrepancy.
2. Resolve and test the candidate environment on authorized Linux/Slurm infrastructure.
3. Run one bounded public-data demonstration, or keep the repository explicitly at orchestration-demo maturity.
4. Confirm authorship, institutional-release permission, and license choice.
5. Review every README claim before changing repository visibility.
