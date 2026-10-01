#!/usr/bin/env bash
#SBATCH --job-name=star_align
#SBATCH -o star_align.%A_%a.out
#SBATCH -e star_align.%A_%a.err
#SBATCH --cpus-per-task=12
#SBATCH --time=24:00:00
#SBATCH --mem=64G
#__RNASEQ_GENERATED_CONFIG__

set -euo pipefail

source "$common_sh"
load_rnaseq_config
load_module_if_set "${STAR_MODULE:-}"

trimmed_read1="$TRIM_DIR/${sample}${TRIM_READ1_SUFFIX}"
trimmed_read2="$TRIM_DIR/${sample}${TRIM_READ2_SUFFIX}"

require_file "$trimmed_read1"
require_file "$trimmed_read2"
require_dir "$STAR_INDEX_DIR"
require_command STAR
require_threads_within_allocation STAR_ALIGN_THREADS
mkdir -p "$ALIGN_DIR"

STAR \
  --runMode alignReads \
  --runThreadN "${STAR_ALIGN_THREADS:-12}" \
  --genomeDir "$STAR_INDEX_DIR" \
  --readFilesIn "$trimmed_read1" "$trimmed_read2" \
  --readFilesCommand zcat \
  --genomeLoad NoSharedMemory \
  --outFileNamePrefix "$ALIGN_DIR/${sample}" \
  --outSAMtype BAM SortedByCoordinate \
  --twopassMode Basic \
  --quantMode GeneCounts
