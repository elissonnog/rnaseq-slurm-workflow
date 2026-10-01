#!/usr/bin/env bash
#SBATCH --job-name=featurecounts
#SBATCH -o featurecounts.%j.out
#SBATCH -e featurecounts.%j.err
#SBATCH --cpus-per-task=12
#SBATCH --time=24:00:00
#SBATCH --mem=64G
#__RNASEQ_GENERATED_CONFIG__

set -euo pipefail

source "$common_sh"
load_rnaseq_config
load_module_if_set "${FEATURECOUNTS_MODULE:-}"

require_var STAR_GTF
require_file "$STAR_GTF"
require_file "$sample_file"
require_command featureCounts
require_threads_within_allocation FEATURECOUNTS_THREADS
mkdir -p "$COUNTS_DIR"

bam_files=()
while IFS= read -r sample_id; do
  bam_file="$ALIGN_DIR/${sample_id}Aligned.sortedByCoord.out.bam"
  require_file "$bam_file"
  bam_files+=("$bam_file")
done < "$sample_file"

count_unit_args=(-p)
case "${FEATURECOUNTS_COUNT_UNIT:-read}" in
  read) ;;
  fragment) count_unit_args+=(--countReadPairs) ;;
  *) printf 'FEATURECOUNTS_COUNT_UNIT must be read or fragment\n' >&2; exit 1 ;;
esac

featureCounts \
  -T "${FEATURECOUNTS_THREADS:-12}" \
  "${count_unit_args[@]}" \
  -s "${FEATURECOUNTS_STRAND:-2}" \
  -t "${FEATURECOUNTS_FEATURE_TYPE:-exon}" \
  -g "${FEATURECOUNTS_ATTRIBUTE_TYPE:-gene_id}" \
  -a "$STAR_GTF" \
  -o "$COUNTS_DIR/featurecounts.txt" \
  "${bam_files[@]}"
