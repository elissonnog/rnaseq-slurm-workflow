#!/usr/bin/env bash

load_rnaseq_config() {
  local script_dir env_file
  script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
  env_file="${RNASEQ_CONFIG:-$script_dir/pipeline.env}"

  if [[ ! -f "$env_file" ]]; then
    printf 'Missing config file: %s\n' "$env_file" >&2
    exit 1
  fi

  # shellcheck disable=SC1090
  source "$env_file"

  FASTQ_DIR="${FASTQ_DIR:-$projPath/fastq}"
  READ1_SUFFIX="${READ1_SUFFIX:-_R1.fastq.gz}"
  READ2_SUFFIX="${READ2_SUFFIX:-_R2.fastq.gz}"
  TRIM_READ1_SUFFIX="${TRIM_READ1_SUFFIX:-_R1_val_1.fq.gz}"
  TRIM_READ2_SUFFIX="${TRIM_READ2_SUFFIX:-_R2_val_2.fq.gz}"
  RAW_FASTQC_DIR="${RAW_FASTQC_DIR:-$projPath/fastqc_raw}"
  TRIM_DIR="${TRIM_DIR:-$projPath/trim_output}"
  ALIGN_DIR="${ALIGN_DIR:-$projPath/star_align}"
  COUNTS_DIR="${COUNTS_DIR:-$projPath/counts}"
  MULTIQC_DIR="${MULTIQC_DIR:-$projPath/multiqc}"
  STAR_INDEX_DIR="${STAR_INDEX_DIR:-$projPath/reference/star_index}"
  STAR_INDEX_MODE="${STAR_INDEX_MODE:-build}"
  FASTQC_THREADS="${FASTQC_THREADS:-2}"
  TRIM_GALORE_CORES="${TRIM_GALORE_CORES:-4}"
  STAR_INDEX_THREADS="${STAR_INDEX_THREADS:-16}"
  STAR_ALIGN_THREADS="${STAR_ALIGN_THREADS:-12}"
  FEATURECOUNTS_THREADS="${FEATURECOUNTS_THREADS:-12}"
  FEATURECOUNTS_COUNT_UNIT="${FEATURECOUNTS_COUNT_UNIT:-read}"
}

load_module_if_set() {
  local module_name="${1:-}"
  if [[ -z "$module_name" ]]; then
    return 0
  fi

  if command -v module >/dev/null 2>&1; then
    module load "$module_name"
  else
    printf 'Skipping module load because environment modules are unavailable: %s\n' "$module_name" >&2
  fi
}

require_var() {
  local var_name="$1"
  if [[ -z "${!var_name:-}" ]]; then
    printf 'Required variable %s is not set\n' "$var_name" >&2
    exit 1
  fi
}

require_file() {
  local path="$1"
  if [[ ! -f "$path" ]]; then
    printf 'Required file not found: %s\n' "$path" >&2
    exit 1
  fi
}

require_dir() {
  local path="$1"
  if [[ ! -d "$path" ]]; then
    printf 'Required directory not found: %s\n' "$path" >&2
    exit 1
  fi
}

require_command() {
  local command_name="$1"
  if ! command -v "$command_name" >/dev/null 2>&1; then
    printf 'Required command not found on PATH: %s\n' "$command_name" >&2
    exit 1
  fi
}

require_threads_within_allocation() {
  local var_name="$1" requested="${!1:-}"
  if [[ ! "$requested" =~ ^[1-9][0-9]*$ ]]; then
    printf '%s must be a positive integer; got: %s\n' "$var_name" "$requested" >&2
    exit 1
  fi
  if [[ -n "${SLURM_CPUS_PER_TASK:-}" ]] && (( requested > SLURM_CPUS_PER_TASK )); then
    printf '%s=%s exceeds SLURM_CPUS_PER_TASK=%s\n' "$var_name" "$requested" "$SLURM_CPUS_PER_TASK" >&2
    exit 1
  fi
}
