#!/usr/bin/env bash
#SBATCH --job-name=fastqc_raw
#SBATCH -o fastqc_raw.%A_%a.out
#SBATCH -e fastqc_raw.%A_%a.err
#SBATCH --cpus-per-task=2
#SBATCH --time=24:00:00
#SBATCH --mem=16G
#__RNASEQ_GENERATED_CONFIG__

set -euo pipefail

source "$(dirname "$0")/common.sh"
load_rnaseq_config
load_module_if_set "${FASTQC_MODULE:-}"

read1="$FASTQ_DIR/${sample}${READ1_SUFFIX}"
read2="$FASTQ_DIR/${sample}${READ2_SUFFIX}"

require_file "$read1"
require_file "$read2"
mkdir -p "$RAW_FASTQC_DIR"

fastqc \
  --threads "${FASTQC_THREADS:-2}" \
  --outdir "$RAW_FASTQC_DIR" \
  "$read1" \
  "$read2"
