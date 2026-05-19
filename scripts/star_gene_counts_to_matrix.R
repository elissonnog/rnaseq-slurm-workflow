#!/usr/bin/env Rscript

args <- commandArgs(trailingOnly = TRUE)

usage <- function() {
  cat(
    "Usage:\n",
    "  Rscript scripts/star_gene_counts_to_matrix.R \\\n",
    "    --sample-file samples.txt \\\n",
    "    --counts-dir star_align \\\n",
    "    --strandedness reverse \\\n",
    "    --output counts.tsv [--strip-ensembl-version]\n",
    sep = ""
  )
}

parse_args <- function(argv) {
  opt <- list(
    sample_file = NULL,
    counts_dir = NULL,
    strandedness = NULL,
    output = NULL,
    strip_ensembl_version = FALSE
  )

  i <- 1L
  while (i <= length(argv)) {
    key <- argv[[i]]
    if (key == "--strip-ensembl-version") {
      opt$strip_ensembl_version <- TRUE
      i <- i + 1L
      next
    }
    if (key %in% c("--help", "-h")) {
      usage()
      quit(save = "no", status = 0L)
    }
    if (i == length(argv)) {
      stop("Missing value for argument: ", key, call. = FALSE)
    }
    value <- argv[[i + 1L]]
    if (key == "--sample-file") {
      opt$sample_file <- value
    } else if (key == "--counts-dir") {
      opt$counts_dir <- value
    } else if (key == "--strandedness") {
      opt$strandedness <- value
    } else if (key == "--output") {
      opt$output <- value
    } else {
      stop("Unknown argument: ", key, call. = FALSE)
    }
    i <- i + 2L
  }

  opt
}

if (length(args) == 0L) {
  usage()
  quit(save = "no", status = 1L)
}

opt <- parse_args(args)

required <- c("sample_file", "counts_dir", "strandedness", "output")
for (name in required) {
  if (is.null(opt[[name]]) || identical(opt[[name]], "")) {
    stop("Missing required argument: ", name, call. = FALSE)
  }
}

if (!requireNamespace("edgeR", quietly = TRUE)) {
  stop("Package 'edgeR' is required for STAR count matrix generation.", call. = FALSE)
}

if (!file.exists(opt$sample_file)) {
  stop("Sample file not found: ", opt$sample_file, call. = FALSE)
}

if (!dir.exists(opt$counts_dir)) {
  stop("Counts directory not found: ", opt$counts_dir, call. = FALSE)
}

samples <- readLines(opt$sample_file, warn = FALSE)
samples <- sub("\r$", "", samples)
samples <- samples[!grepl("^\\s*(#|$)", samples)]

if (length(samples) == 0L) {
  stop("No sample identifiers were found in: ", opt$sample_file, call. = FALSE)
}

star_col <- switch(
  opt$strandedness,
  unstranded = 2L,
  forward = 3L,
  reverse = 4L,
  stop(
    "strandedness must be one of: unstranded, forward, reverse",
    call. = FALSE
  )
)

files <- paste0(samples, "ReadsPerGene.out.tab")
counts <- edgeR::readDGE(
  files = files,
  path = opt$counts_dir,
  columns = c(1, star_col),
  header = FALSE
)

counts <- counts$counts[-seq_len(4), , drop = FALSE]
colnames(counts) <- samples

if (opt$strip_ensembl_version) {
  rownames(counts) <- sub("\\.[0-9]+$", "", rownames(counts))
}

write.table(
  counts,
  file = opt$output,
  sep = "\t",
  quote = FALSE,
  col.names = NA
)
