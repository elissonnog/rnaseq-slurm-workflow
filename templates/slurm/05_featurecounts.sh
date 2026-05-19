#!/usr/bin/env bash
#SBATCH --job-name=featurecounts
#SBATCH -o featurecounts.%j.out
#SBATCH -e featurecounts.%j.err
#SBATCH --cpus-per-task=12
#SBATCH --time=24:00:00
#SBATCH --mem=64G
#__RNASEQ_GENERATED_CONFIG__

set -euo pipefail

source "$(dirname "$0")/common.sh"
load_rnaseq_config
load_module_if_set "${FEATURECOUNTS_MODULE:-}"

require_var STAR_GTF
require_file "$STAR_GTF"
mkdir -p "$COUNTS_DIR"

shopt -s nullglob
bam_files=( "$ALIGN_DIR"/*Aligned.sortedByCoord.out.bam )
shopt -u nullglob

if (( ${#bam_files[@]} == 0 )); then
  printf 'No aligned BAM files found in %s\n' "$ALIGN_DIR" >&2
  exit 1
fi

featureCounts \
  -T "${FEATURECOUNTS_THREADS:-12}" \
  -p \
  -s "${FEATURECOUNTS_STRAND:-2}" \
  -t "${FEATURECOUNTS_FEATURE_TYPE:-exon}" \
  -g "${FEATURECOUNTS_ATTRIBUTE_TYPE:-gene_id}" \
  -a "$STAR_GTF" \
  -o "$COUNTS_DIR/featurecounts.txt" \
  "${bam_files[@]}"
