#!/usr/bin/env bash
#SBATCH --job-name=multiqc
#SBATCH -o multiqc.%j.out
#SBATCH -e multiqc.%j.err
#SBATCH --cpus-per-task=2
#SBATCH --time=24:00:00
#SBATCH --mem=16G
#__RNASEQ_GENERATED_CONFIG__

set -euo pipefail

source "$common_sh"
load_rnaseq_config
load_module_if_set "${MULTIQC_MODULE:-}"
require_command multiqc

mkdir -p "$MULTIQC_DIR"

multiqc \
  -n "${MULTIQC_REPORT_NAME:-multiqc_rnaseq_report.html}" \
  -o "$MULTIQC_DIR" \
  "$projPath"
