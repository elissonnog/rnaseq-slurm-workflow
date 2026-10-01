#!/usr/bin/env bash
#SBATCH --job-name=star_index
#SBATCH -o star_index.%j.out
#SBATCH -e star_index.%j.err
#SBATCH --cpus-per-task=16
#SBATCH --time=24:00:00
#SBATCH --mem=64G
#__RNASEQ_GENERATED_CONFIG__

set -euo pipefail

source "$common_sh"
load_rnaseq_config
load_module_if_set "${STAR_MODULE:-}"

case "${STAR_INDEX_MODE:-build}" in
  use_existing)
    require_dir "$STAR_INDEX_DIR"
    printf 'Using existing STAR index: %s\n' "$STAR_INDEX_DIR"
    exit 0
    ;;
  build) ;;
  *) printf 'STAR_INDEX_MODE must be build or use_existing\n' >&2; exit 1 ;;
esac

require_var STAR_FASTA
require_var STAR_GTF
require_file "$STAR_FASTA"
require_file "$STAR_GTF"
require_command STAR
require_threads_within_allocation STAR_INDEX_THREADS

mkdir -p "$STAR_INDEX_DIR"

STAR \
  --runThreadN "${STAR_INDEX_THREADS:-16}" \
  --runMode genomeGenerate \
  --genomeDir "$STAR_INDEX_DIR" \
  --genomeFastaFiles "$STAR_FASTA" \
  --sjdbGTFfile "$STAR_GTF" \
  --sjdbOverhang "${STAR_SJDB_OVERHANG:-100}"
