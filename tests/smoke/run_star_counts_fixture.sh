#!/usr/bin/env bash

set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
fixture_dir="$repo_root/tests/fixtures/star-counts"
tmp_output="$(mktemp /tmp/star_counts_XXXXXX.tsv)"
trap 'rm -f "$tmp_output"' EXIT

Rscript --vanilla "$repo_root/scripts/star_gene_counts_to_matrix.R" \
  --sample-file "$fixture_dir/samples.txt" \
  --counts-dir "$fixture_dir" \
  --strandedness reverse \
  --strip-ensembl-version \
  --output "$tmp_output"

diff -u "$fixture_dir/expected-reverse.tsv" "$tmp_output"
