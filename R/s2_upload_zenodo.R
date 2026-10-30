## =============================================================================
## s2_upload_zenodo.R
##
## Archive the OSSL v1.3 per-dataset files on Zenodo as a new version of the
## OSSL record (v1.2: https://zenodo.org/records/7599269, SS4GG community).
##
## Steps
##   1. Locate the v1.3 files on the mounted public bucket (from their URLs)
##   2. Build manifest.csv (path in zip, table, format, rows, cols, size, md5, URL)
##   3. Zip each dataset into OSSL_v1.3_<DATASET>.zip
##   4. Create a Zenodo draft (new version of the previous record), sync files,
##      and set metadata. The script never publishes: review the draft online
##      and click Publish on the Zenodo website.
##
## Re-running is safe: zips and uploads that are already done are skipped,
## and the draft id is saved so the same draft is reused.
##
## Requirements
##   install.packages(c("httr2", "arrow", "zip", "jsonlite"))
##   Personal access token with deposit:write:
##     ~/secrets/zenodo_token                  # https://sandbox.zenodo.org
##     ~/secrets/zenodo_sandbox_token          # https://zenodo.org
##    (fallback: ZENODO_TOKEN / ZENODO_SANDBOX_TOKEN env vars). Never commit tokens.
##
## Disk: zips are written to the mounted private bucket. If it is mounted with
## gcsfuse, each zip is staged in gcsfuse's local temp dir while being written,
## so the VM needs local free space for the largest zip (KSSL).
## =============================================================================

library("httr2")
library("arrow")
library("zip")
library("jsonlite")

`%||%` <- function(x, y) if (is.null(x)) y else x

## ---- Configuration ----------------------------------------------------------

ossl_version <- "v1.3"

## Test the whole flow on the sandbox first. In the sandbox, a fresh deposition
## is created (record 7599269 only exists on production Zenodo).
use_sandbox <- FALSE

## Latest published version of the OSSL record on production Zenodo.
## The new-version action must be called on the LATEST version of the concept.
previous_record_id <- 7599269

## Inputs: file list (dataset_code, ossl_file, public_url) and the record README.
## Paths are relative to the ossl-imports project root.
files_csv  <- "out/ossl_individual_datasets_urls_v1.3.csv"
readme_src <- "R/zenodo_README.md"

## Public URLs are mapped to the mounted public bucket by swapping this prefix:
##   https://storage.googleapis.com/soilspec4gg-public/datasets/KSSL/x.parquet
##   -> ~/mnt-ossl-public/datasets/KSSL/x.parquet
public_url_prefix <- "https://storage.googleapis.com/soilspec4gg-public/"
public_mount      <- path.expand("~/mnt-ossl-public")

## Working folder on the mounted private (dev) bucket
work_dir   <- path.expand("~/mnt-ossl-private/zenodo")
upload_dir <- file.path(work_dir, paste0("upload_", ossl_version)) # zips + manifest.csv + README.md
draft_file <- file.path(work_dir, if (use_sandbox) "draft_id_sandbox.txt" else "draft_id.txt")

## ---- Zenodo metadata --------------------------------------------------------
## TODO: review creators for v1.3 (v1.2 list kept as a starting point).

manual_url <- "https://docs.soilspectroscopy.org"

zenodo_metadata <- list(
  upload_type = "dataset",
  title = "Open Soil Spectral Library (OSSL)",
  version = ossl_version,
  publication_date = format(Sys.Date(), "%Y-%m-%d"),
  creators = list(
    list(
      name = "Safanelli, José Lucas",
      affiliation = "Woodwell Climate Research Center",
      orcid = "0000-0001-5410-5762"
    ),
    list(
      name = "Hengl, Tomislav",
      affiliation = "OpenGeoHub",
      orcid = "0000-0002-9921-5129"
    ),
    list(
      name = "Sanderman, Jonathan",
      affiliation = "Woodwell Climate Research Center",
      orcid = "0000-0002-3215-1706"
    ),
    list(
      name = "Parente, Leandro",
      affiliation = "OpenGeoHub",
      orcid = "0000-0003-1589-0467"
    )
  ),
  description = paste0(
    "<p><strong>Open Soil Spectral Library (OSSL) ",
    ossl_version,
    "</strong>. ",
    "Harmonized soil site, soil laboratory and spectral (MIR, VisNIR, NIR) data. ",
    "From v1.3 onward, each source dataset is distributed separately: ",
    "this record contains one zip archive per dataset (CSV and Parquet), ",
    "a <code>manifest.csv</code> listing every archived file with checksums, ",
    "and a <code>README.md</code>.</p>",
    "<p>Dataset descriptions, original producers, licenses, references, ",
    "variable definitions and usage instructions are maintained in the OSSL manual: ",
    "<a href=\"",
    manual_url,
    "\">",
    manual_url,
    "</a>.</p>",
    "<p>Source datasets belong to their original producers. When using a dataset, ",
    "please cite this record and the original source listed in the OSSL manual.</p>",
    "<p><a href=\"https://soilspectroscopy.org/\">Soil Spectroscopy for the Global Good</a> ",
    "was funded by the USDA NIFA Food and Agriculture ",
    "Cyberinformatics Tools Program (Award #2020-67021-32467) ",
    "and is currently maintained with limited institutional support and indirect funding.</p>"
  ),
  access_right = "open",
  license = "cc-by-4.0",
  keywords = list(
    "soil",
    "spectroscopy",
    "soil spectral library",
    "MIR",
    "VisNIR",
    "NIR",
    "machine learning",
    "carbon",
    "pH"
  ),
  related_identifiers = list(
    list(
      identifier = manual_url,
      relation = "isDocumentedBy",
      resource_type = "publication"
    )
  ),
  communities = list(list(identifier = "ss4gg"))
)

## The community only exists on production Zenodo
if (use_sandbox) zenodo_metadata$communities <- NULL

## ---- Helpers ----------------------------------------------------------------

zen_base  <- if (use_sandbox) "https://sandbox.zenodo.org/api" else "https://zenodo.org/api"

## Token: read from ~/secrets (one line, the token only); fall back to an env var
token_file <- path.expand(
  if (use_sandbox) {
    "~/secrets/zenodo_sandbox_token"
  } else {
    "~/secrets/zenodo_token"
  }
)

zen_token <- if (file.exists(token_file)) {
  trimws(readLines(token_file, n = 1, warn = FALSE))
} else {
  Sys.getenv(if (use_sandbox) "ZENODO_SANDBOX_TOKEN" else "ZENODO_TOKEN")
}

if (!nzchar(zen_token)) {
  stop("Zenodo token not found in ", token_file, " or the environment.")
}

zen_req <- function(path_or_url) {
  url <- if (grepl("^https?://", path_or_url)) path_or_url else paste0(zen_base, path_or_url)
  request(url) |>
    req_auth_bearer_token(zen_token) |>
    req_retry(max_tries = 5, backoff = function(i) 10 * i) |>
    req_timeout(3 * 60 * 60)  # large uploads
}

md5_of <- function(f) unname(tools::md5sum(f))

parquet_dims <- function(f) {
  r <- arrow::ParquetFileReader$create(f)
  c(n_rows = as.numeric(r$num_rows), n_cols = as.numeric(r$num_columns))
}

## ---- 1. Locate files on the public mount ------------------------------------

dir.create(upload_dir, recursive = TRUE, showWarnings = FALSE)

## Reads comma- or tab-separated files
files <- read.csv(files_csv, stringsAsFactors = FALSE,
                  sep = if (grepl("\t", readLines(files_csv, n = 1))) "\t" else ",")

stopifnot(all(c("dataset_code", "ossl_file", "public_url") %in% names(files)))

if (!all(startsWith(files$public_url, public_url_prefix))) {
  stop("Some URLs do not start with public_url_prefix: ",
       paste(head(files$public_url[!startsWith(files$public_url, public_url_prefix)]), collapse = ", "))
}

files$rel_path   <- substring(files$public_url, nchar(public_url_prefix) + 1)  # datasets/<DS>/<file>
files$local_path <- file.path(public_mount, files$rel_path)

missing <- !file.exists(files$local_path)

if (any(missing)) {
  stop(sum(missing), " files not found on the public mount, e.g. ",
       paste(head(files$local_path[missing], 3), collapse = ", "))
}

## Zips mirror the layout <DATASET>/<file>, rooted at the parent of the dataset folders
zip_root <- unique(dirname(dirname(files$local_path)))
if (length(zip_root) != 1) stop("Dataset folders are not under a single parent folder: ", paste(zip_root, collapse = ", "))

## ---- 2. Manifest ------------------------------------------------------------

pattern <- sprintf("^ossl_([a-z]+)_%s\\.(csv\\.gz|parquet)$", gsub(".", "\\.", ossl_version, fixed = TRUE))
if (!all(grepl(pattern, files$ossl_file))) {
  stop("Unexpected file names: ",
       paste(files$ossl_file[!grepl(pattern, files$ossl_file)], collapse = ", "))
}

manifest <- data.frame(
  dataset_code = files$dataset_code,
  archive      = sprintf("OSSL_%s_%s.zip", ossl_version, files$dataset_code),
  file         = file.path(files$dataset_code, files$ossl_file),  # path inside the zip
  table        = sub(pattern, "\\1", files$ossl_file),
  format       = sub(pattern, "\\2", files$ossl_file),
  n_rows       = NA_real_,
  n_cols       = NA_real_,
  size_bytes   = file.size(files$local_path),
  md5          = vapply(files$local_path, md5_of, character(1), USE.NAMES = FALSE),
  public_url   = files$public_url,
  stringsAsFactors = FALSE
)

## Row/column counts from Parquet metadata (no full read needed)
is_pq <- manifest$format == "parquet"
dims <- t(vapply(files$local_path[is_pq], parquet_dims, numeric(2), USE.NAMES = FALSE))
manifest$n_rows[is_pq] <- dims[,1]
manifest$n_cols[is_pq] <- dims[,2]

## CSV and Parquet hold the same table: copy counts from the Parquet sibling
key <- paste(manifest$dataset_code, manifest$table)
idx <- match(key, key[is_pq])
manifest$n_rows[!is_pq] <- manifest$n_rows[is_pq][idx[!is_pq]]
manifest$n_cols[!is_pq] <- manifest$n_cols[is_pq][idx[!is_pq]]

write.csv(manifest, file.path(upload_dir, "manifest.csv"), row.names = FALSE)
file.copy(readme_src, file.path(upload_dir, "README.md"), overwrite = TRUE)

## ---- 3. Zip per dataset -----------------------------------------------------
## Each zip contains a <DATASET>/ folder, so extracting several zips together
## does not overwrite same-named files. Inputs are already compressed, so a
## low compression level is used for speed.

for (ds in unique(manifest$dataset_code)) {
  zf <- file.path(upload_dir, sprintf("OSSL_%s_%s.zip", ossl_version, ds))
  if (file.exists(zf)) next
  message("Zipping ", ds)
  tmp <- paste0(zf, ".part")
  zip::zip(tmp, files = manifest$file[manifest$dataset_code == ds],
           root = zip_root, mode = "mirror", compression_level = 1)
  file.rename(tmp, zf)
}

upload_files <- c(
  file.path(upload_dir, "README.md"),
  file.path(upload_dir, "manifest.csv"),
  file.path(upload_dir, sprintf("OSSL_%s_%s.zip", ossl_version, unique(manifest$dataset_code)))
)

total_gb <- sum(file.size(upload_files)) / 1e9

# Request a quota increase first if total size exceeds Zenodo's default 50 GB per record.
# Cannot upload more than 100 files as it exceeds Zenodo's default per-record limit.
message(sprintf("%d files to upload, %.1f GB total", length(upload_files), total_gb))

## ---- 4. Zenodo draft --------------------------------------------------------

if (file.exists(draft_file)) {
  draft_id <- readLines(draft_file, n = 1)
  message("Reusing draft ", draft_id)
} else if (use_sandbox) {
  dep <- zen_req("/deposit/depositions") |>
    req_method("POST") |>
    req_body_raw("{}", type = "application/json") |>
    req_perform() |>
    resp_body_json()
  draft_id <- as.character(dep$id)
  writeLines(draft_id, draft_file)
} else {
  resp <- zen_req(sprintf("/deposit/depositions/%s/actions/newversion", previous_record_id)) |>
    req_method("POST") |>
    req_perform() |>
    resp_body_json()
  ## The response points to the new draft (older API: links$latest_draft)
  draft_url <- resp$links$latest_draft %||% resp$links$self
  draft_id  <- sub(".*/", "", draft_url)
  writeLines(draft_id, draft_file)
}

dep <- zen_req(sprintf("/deposit/depositions/%s", draft_id)) |> req_perform() |> resp_body_json()
if (isTRUE(dep$submitted) || identical(dep$state, "done")) {
  stop("Deposition ", draft_id, " is already published. Delete ", draft_file, " to start a new draft.")
}

bucket <- dep$links$bucket

## Sync files: drop files carried over from v1.2 (or stale uploads), keep
## files already uploaded with the same checksum, upload the rest.
remote <- zen_req(sprintf("/deposit/depositions/%s/files", draft_id)) |> req_perform() |> resp_body_json()
remote_md5 <- setNames(vapply(remote, function(x) sub("^md5:", "", x$checksum), character(1)),
                       vapply(remote, function(x) x$filename, character(1)))
local_md5 <- setNames(vapply(upload_files, md5_of, character(1)), basename(upload_files))

for (r in remote) {
  keep <- r$filename %in% names(local_md5) && identical(sub("^md5:", "", r$checksum), local_md5[[r$filename]])
  if (!keep) {
    message("Removing from draft: ", r$filename)
    zen_req(sprintf("/deposit/depositions/%s/files/%s", draft_id, r$id)) |>
      req_method("DELETE") |>
      req_perform()
  }
}

for (f in upload_files) {
  fn <- basename(f)
  if (fn %in% names(remote_md5) && identical(remote_md5[[fn]], local_md5[[fn]])) {
    message("Already uploaded: ", fn)
    next
  }
  message(sprintf("Uploading %s (%.2f GB)", fn, file.size(f) / 1e9))
  res <- zen_req(paste0(bucket, "/", utils::URLencode(fn, reserved = TRUE))) |>
    req_method("PUT") |>
    req_body_file(f, type = "application/octet-stream") |>
    req_perform() |>
    resp_body_json()
  if (!identical(sub("^md5:", "", res$checksum), local_md5[[fn]])) {
    stop("Checksum mismatch after upload: ", fn)
  }
}

## Metadata
zen_req(sprintf("/deposit/depositions/%s", draft_id)) |>
  req_method("PUT") |>
  req_body_json(list(metadata = zenodo_metadata)) |>
  req_perform()

dep <- zen_req(sprintf("/deposit/depositions/%s", draft_id)) |> req_perform() |> resp_body_json()
message("Draft ready for review: ", dep$links$html)
message("Reserved DOI: ", dep$metadata$prereserve_doi$doi %||% "(see draft page)")
message("Review the draft online and publish it from the Zenodo website.")
