#!/usr/bin/env bash

set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
tmp_project="$(mktemp -d /tmp/rnaseq_project_XXXXXX)"
tmp_output="$(mktemp -d /tmp/rnaseq_demo_XXXXXX)"

bash -n "$repo_root/bin/rnaseq-init"
bash -n "$repo_root/bin/rnaseq-submit"
perl -c "$repo_root/scripts/generate_experiment.pl"
perl -c "$repo_root/scripts/submit_chain.pl"

if command -v Rscript >/dev/null 2>&1; then
  Rscript --vanilla -e "parse(file='${repo_root}/scripts/star_gene_counts_to_matrix.R')" >/dev/null
fi

for file in "$repo_root"/templates/slurm/common.sh "$repo_root"/templates/slurm/*.sh "$repo_root"/nextflow/*.sh; do
  bash -n "$file"
done

"$repo_root/bin/rnaseq-init" \
  --project-dir "$tmp_project" \
  --sample-file "$repo_root/examples/slurm-dry-run/samples.txt" \
  --experiment demo_run \
  --output-dir "$tmp_output"

for file in "$tmp_output"/*.sh; do
  bash -n "$file"
done

"$repo_root/bin/rnaseq-submit" --experiment-dir "$tmp_output" --dry-run
