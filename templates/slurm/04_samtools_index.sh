#!/usr/bin/env bash
#SBATCH --job-name=samtools_index
#SBATCH -o samtools_index.%A_%a.out
#SBATCH -e samtools_index.%A_%a.err
#SBATCH --cpus-per-task=2
#SBATCH --time=24:00:00
#SBATCH --mem=16G
#__RNASEQ_GENERATED_CONFIG__

set -euo pipefail

source "$common_sh"
load_rnaseq_config
load_module_if_set "${SAMTOOLS_MODULE:-}"

bam_file="$ALIGN_DIR/${sample}Aligned.sortedByCoord.out.bam"
require_file "$bam_file"
require_command samtools

samtools index "$bam_file"
