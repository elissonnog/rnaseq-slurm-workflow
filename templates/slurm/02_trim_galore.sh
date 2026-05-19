#!/usr/bin/env bash
#SBATCH --job-name=trim_galore
#SBATCH -o trim_galore.%A_%a.out
#SBATCH -e trim_galore.%A_%a.err
#SBATCH --cpus-per-task=4
#SBATCH --time=24:00:00
#SBATCH --mem=32G
#__RNASEQ_GENERATED_CONFIG__

set -euo pipefail

source "$(dirname "$0")/common.sh"
load_rnaseq_config
load_module_if_set "${TRIM_GALORE_MODULE:-}"
load_module_if_set "${FASTQC_MODULE:-}"

read1="$FASTQ_DIR/${sample}${READ1_SUFFIX}"
read2="$FASTQ_DIR/${sample}${READ2_SUFFIX}"

require_file "$read1"
require_file "$read2"
mkdir -p "$TRIM_DIR"

trim_galore \
  --cores "${TRIM_GALORE_CORES:-4}" \
  --fastqc \
  --illumina \
  --length "${TRIM_MIN_LENGTH:-50}" \
  --output_dir "$TRIM_DIR" \
  --paired "$read1" "$read2"
