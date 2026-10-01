#!/usr/bin/env bash

set -euo pipefail

script_dir="${RNASEQ_NF_SCRIPT_DIR:-$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)}"
env_file="${1:-$script_dir/../config/nextflow.env}"

if [[ -n "${RNASEQ_NF_ENV:-}" ]]; then
  env_file="$RNASEQ_NF_ENV"
fi
env_file="$(cd "$(dirname "$env_file")" && pwd)/$(basename "$env_file")"

if [[ ! -f "$env_file" ]]; then
  printf 'Missing Nextflow env file: %s\n' "$env_file" >&2
  exit 1
fi

# shellcheck disable=SC1090
set -a
source "$env_file"
set +a

if [[ -z "${SLURM_JOB_ID:-}" ]] && command -v sbatch >/dev/null 2>&1; then
  sbatch_cmd=(
    sbatch
    --job-name "${NEXTFLOW_JOB_NAME:-nfcore_rnaseq}"
    --time "${NEXTFLOW_SLURM_TIME:-24:00:00}"
    --cpus-per-task "${NEXTFLOW_SLURM_CPUS:-4}"
    --mem "${NEXTFLOW_SLURM_MEM:-64G}"
    --export "ALL,RNASEQ_NF_SCRIPT_DIR=$script_dir,RNASEQ_NF_ENV=$env_file"
  )

  if [[ -n "${NEXTFLOW_SLURM_PARTITION:-}" ]]; then
    sbatch_cmd+=(--partition "${NEXTFLOW_SLURM_PARTITION}")
  fi

  if [[ -n "${NEXTFLOW_SBATCH_EXTRA:-}" ]]; then
    # shellcheck disable=SC2206
    extra_args=( ${NEXTFLOW_SBATCH_EXTRA} )
    sbatch_cmd+=("${extra_args[@]}")
  fi

  sbatch_cmd+=("$script_dir/submit_nfcore_rnaseq.sh")

  printf 'Submitting Nextflow wrapper with:'
  printf ' %q' "${sbatch_cmd[@]}"
  printf '\n'

  "${sbatch_cmd[@]}"
  exit 0
fi

if [[ -n "${NEXTFLOW_CONDA_ENV:-}" ]]; then
  if [[ -f "$HOME/.bashrc" ]]; then
    # shellcheck disable=SC1090
    source "$HOME/.bashrc"
  fi
  conda activate "$NEXTFLOW_CONDA_ENV"
fi

exec bash "$script_dir/run_nfcore_rnaseq.sh" "$env_file"
