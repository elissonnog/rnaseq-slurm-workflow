#!/usr/bin/env bash

set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
tmp_project="$(mktemp -d /tmp/rnaseq_project_XXXXXX)"
tmp_output="$(mktemp -d /tmp/rnaseq_demo_XXXXXX)"
tmp_spool="$(mktemp -d /tmp/rnaseq_spool_XXXXXX)"
tmp_bin="$(mktemp -d /tmp/rnaseq_bin_XXXXXX)"
trap 'rm -rf "$tmp_project" "$tmp_output" "$tmp_spool" "$tmp_bin"' EXIT

bash -n "$repo_root/bin/rnaseq-init"
bash -n "$repo_root/bin/rnaseq-submit"
perl -c "$repo_root/scripts/generate_experiment.pl"
perl -c "$repo_root/scripts/submit_chain.pl"

if command -v Rscript >/dev/null 2>&1; then
  Rscript --vanilla -e "parse(file='${repo_root}/scripts/star_gene_counts_to_matrix.R')" >/dev/null
fi

for file in "$repo_root"/templates/slurm/common.sh "$repo_root"/templates/slurm/*.sh "$repo_root"/nextflow/*.sh; do
  bash -n "$file"
done

"$repo_root/bin/rnaseq-init" \
  --project-dir "$tmp_project" \
  --sample-file "$repo_root/examples/slurm-dry-run/samples.txt" \
  --experiment demo_run \
  --output-dir "$tmp_output"

for file in "$tmp_output"/*.sh; do
  bash -n "$file"
done

cmp "$repo_root/examples/slurm-dry-run/samples.txt" "$tmp_output/samples.txt"

# A Slurm-spooled copy must still source the absolute common.sh path embedded
# by the renderer, rather than looking beside the copied script.
mkdir -p "$tmp_project/star_align" "$tmp_project/counts"
touch "$tmp_project/annotation.gtf"
while IFS= read -r sample_id; do
  touch "$tmp_project/star_align/${sample_id}Aligned.sortedByCoord.out.bam"
done < "$tmp_output/samples.txt"
cat > "$tmp_project/test.env" <<EOF
STAR_GTF="$tmp_project/annotation.gtf"
ALIGN_DIR="$tmp_project/star_align"
COUNTS_DIR="$tmp_project/counts"
FEATURECOUNTS_THREADS=12
FEATURECOUNTS_COUNT_UNIT="fragment"
EOF
cat > "$tmp_bin/featureCounts" <<'EOF'
#!/usr/bin/env bash
printf '%s\n' "$@" > "${FEATURECOUNTS_TEST_LOG:?}"
EOF
chmod +x "$tmp_bin/featureCounts"
cp "$tmp_output/05_featurecounts.sh" "$tmp_spool/slurm_script"
PATH="$tmp_bin:$PATH" RNASEQ_CONFIG="$tmp_project/test.env" \
  FEATURECOUNTS_TEST_LOG="$tmp_project/featurecounts.args" \
  SLURM_CPUS_PER_TASK=12 bash "$tmp_spool/slurm_script"
grep -Fx -- '--countReadPairs' "$tmp_project/featurecounts.args"
expected_bams="$tmp_project/expected-bams.txt"
while IFS= read -r sample_id; do
  printf '%s\n' "$tmp_project/star_align/${sample_id}Aligned.sortedByCoord.out.bam"
done < "$tmp_output/samples.txt" > "$expected_bams"
grep -F 'Aligned.sortedByCoord.out.bam' "$tmp_project/featurecounts.args" > "$tmp_project/actual-bams.txt"
cmp "$expected_bams" "$tmp_project/actual-bams.txt"

# Input manifests are normalized; invalid and duplicate identifiers fail early.
printf '  SAMPLE_A\r\n\n# comment\nSAMPLE-B  \n' > "$tmp_project/dirty-samples.txt"
"$repo_root/bin/rnaseq-init" --project-dir "$tmp_project" \
  --sample-file "$tmp_project/dirty-samples.txt" --experiment normalized \
  --output-dir "$tmp_project/normalized"
printf 'SAMPLE_A\nSAMPLE-B\n' > "$tmp_project/expected-samples.txt"
cmp "$tmp_project/expected-samples.txt" "$tmp_project/normalized/samples.txt"
printf 'S1\nS1\n' > "$tmp_project/duplicate-samples.txt"
if "$repo_root/bin/rnaseq-init" --project-dir "$tmp_project" \
  --sample-file "$tmp_project/duplicate-samples.txt" --experiment duplicate \
  --output-dir "$tmp_project/duplicate" 2> "$tmp_project/duplicate.err"; then
  echo 'Duplicate sample IDs unexpectedly succeeded' >&2
  exit 1
fi
grep -F 'Duplicate sample ID' "$tmp_project/duplicate.err"
printf 'S1\nbad/sample\n' > "$tmp_project/unsafe-samples.txt"
if "$repo_root/bin/rnaseq-init" --project-dir "$tmp_project" \
  --sample-file "$tmp_project/unsafe-samples.txt" --experiment unsafe \
  --output-dir "$tmp_project/unsafe" 2> "$tmp_project/unsafe.err"; then
  echo 'Unsafe sample ID unexpectedly succeeded' >&2
  exit 1
fi
grep -F 'Unsafe sample ID' "$tmp_project/unsafe.err"

# Construct both Nextflow paths with fake executables; do not run Nextflow or Slurm.
cat > "$tmp_bin/nextflow" <<'EOF'
#!/usr/bin/env bash
printf '%s\n' "$@" > "${NEXTFLOW_TEST_LOG:?}"
printf '%s\n' "${NEXTFLOW_INPUT_SHEET:-}" > "${NEXTFLOW_ENV_LOG:?}"
EOF
cat > "$tmp_bin/sbatch" <<'EOF'
#!/usr/bin/env bash
printf '%s\n' "$@" > "${SBATCH_TEST_LOG:?}"
EOF
chmod +x "$tmp_bin/nextflow" "$tmp_bin/sbatch"
cat > "$tmp_project/nextflow.env" <<EOF
NEXTFLOW_INPUT_SHEET="$tmp_project/samplesheet.csv"
NEXTFLOW_OUTDIR="$tmp_project/nf-output"
NFCORE_RNASEQ_REV="3.26.0"
EOF
touch "$tmp_project/samplesheet.csv"
PATH="$tmp_bin:$PATH" NEXTFLOW_TEST_LOG="$tmp_project/nextflow.args" \
  NEXTFLOW_ENV_LOG="$tmp_project/nextflow.env-value" \
  bash "$repo_root/nextflow/run_nfcore_rnaseq.sh" "$tmp_project/nextflow.env"
grep -Fx -- "$tmp_project/samplesheet.csv" "$tmp_project/nextflow.env-value"
PATH="$tmp_bin:$PATH" SBATCH_TEST_LOG="$tmp_project/sbatch.args" \
  bash "$repo_root/nextflow/submit_nfcore_rnaseq.sh" "$tmp_project/nextflow.env"
grep -F "RNASEQ_NF_SCRIPT_DIR=$repo_root/nextflow,RNASEQ_NF_ENV=$tmp_project/nextflow.env" "$tmp_project/sbatch.args"
grep -Fx -- "$repo_root/nextflow/submit_nfcore_rnaseq.sh" "$tmp_project/sbatch.args"

actual_plan="$tmp_output/submission_plan.txt"
normalized_plan="$tmp_output/submission_plan.normalized.txt"
"$repo_root/bin/rnaseq-submit" --experiment-dir "$tmp_output" --dry-run > "$actual_plan"
physical_output="$(cd "$tmp_output" && pwd -P)"
sed "s#${physical_output}#<experiment_dir>#g" "$actual_plan" > "$normalized_plan"
diff -u \
  "$repo_root/examples/slurm-dry-run/expected_submission_plan.txt" \
  "$normalized_plan"

cat "$normalized_plan"
