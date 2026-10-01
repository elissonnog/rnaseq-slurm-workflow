# Candidate Pinned Toolchain

`slurm-tools.yml` mirrors the exact command-line versions recorded in `config/software_versions.tsv.example` and represented by the historical workflow templates.

This file has not been solved on the current Mac because Conda is unavailable, and it has not been exercised on Linux/Slurm. Treat it as a review candidate rather than proof that the historical environment can still be reconstructed. The optional STAR count-matrix R utility and the separate nf-core/Nextflow execution path require their own resolved environments.
