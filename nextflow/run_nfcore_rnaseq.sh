#!/usr/bin/env bash

set -euo pipefail

script_dir="${RNASEQ_NF_SCRIPT_DIR:-$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)}"
env_file="${1:-$script_dir/../config/nextflow.env}"

if [[ ! -f "$env_file" ]]; then
  printf 'Missing Nextflow env file: %s\n' "$env_file" >&2
  printf 'Copy config/nextflow.env.example to config/nextflow.env and edit it first.\n' >&2
  exit 1
fi
env_file="$(cd "$(dirname "$env_file")" && pwd)/$(basename "$env_file")"

# shellcheck disable=SC1090
set -a
source "$env_file"
set +a

require_var() {
  local var_name="$1"
  if [[ -z "${!var_name:-}" ]]; then
    printf 'Required variable %s is not set in %s\n' "$var_name" "$env_file" >&2
    exit 1
  fi
}

require_var NEXTFLOW_INPUT_SHEET
require_var NEXTFLOW_OUTDIR

cmd=(
  nextflow
  run
  "${NFCORE_RNASEQ_PIPELINE:-nf-core/rnaseq}"
  -c
  "$script_dir/nextflow.config"
  --input
  "$NEXTFLOW_INPUT_SHEET"
  --outdir
  "$NEXTFLOW_OUTDIR"
)

if [[ -n "${NFCORE_RNASEQ_REV:-}" ]]; then
  cmd+=(-r "$NFCORE_RNASEQ_REV")
fi

if [[ -n "${NEXTFLOW_ALIGNER:-}" ]]; then
  cmd+=(--aligner "$NEXTFLOW_ALIGNER")
fi

if [[ -n "${NEXTFLOW_GENOME:-}" ]]; then
  cmd+=(--genome "$NEXTFLOW_GENOME")
fi

if [[ -n "${NEXTFLOW_FASTA:-}" ]]; then
  cmd+=(--fasta "$NEXTFLOW_FASTA")
fi

if [[ -n "${NEXTFLOW_GTF:-}" ]]; then
  cmd+=(--gtf "$NEXTFLOW_GTF")
fi

if [[ -n "${NEXTFLOW_PROFILE:-}" ]]; then
  cmd+=(-profile "$NEXTFLOW_PROFILE")
fi

if [[ -n "${NEXTFLOW_WORKDIR:-}" ]]; then
  cmd+=(-work-dir "$NEXTFLOW_WORKDIR")
fi

if [[ "${NEXTFLOW_RESUME:-false}" == "true" ]]; then
  cmd+=(-resume)
fi

if [[ -n "${NEXTFLOW_EXTRA_PARAMS:-}" ]]; then
  # shellcheck disable=SC2206
  extra_args=( ${NEXTFLOW_EXTRA_PARAMS} )
  cmd+=("${extra_args[@]}")
fi

printf 'Running:'
printf ' %q' "${cmd[@]}"
printf '\n'

"${cmd[@]}"
