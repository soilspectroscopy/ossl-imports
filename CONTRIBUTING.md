# Contributing a dataset to OSSL

Each dataset in `ossl-imports` is processed by one executable Quarto document (`README.qmd`). That document reads the raw files, standardizes them to OSSL Level 0, and renders to a GitHub-readable `README.md`.

**Rules**

- Raw data stays in `~/mnt-ossl-private/database/datasets/<CODE>/`. Never commit raw files or credentials (process or share with us).
- Variable names, methods, and units must follow the OSSL Level 0 vocabularies in [`out/`](out/).
- Spectra are resampled to the standard OSSL grids:
  - MIR: 600–4000 cm⁻¹, every 2 cm⁻¹
  - VisNIR: 350–2500 nm, every 2 nm

---

## Setup

You need **R ≥ 4.2** and **Quarto ≥ 1.3**. Install the R packages:

```r
install.packages(c(
  "tidyverse", "data.table", "lubridate", "units", "readxl", "stringr",
  "tmap", "sf", "rnaturalearth", "skimr", "prospectr", "tictoc",
  "nanoparquet", "fs", "openssl"
))
```

Pick a dataset code (3–8 uppercase letters or digits, e.g. `CAF`, `KSSL`). Then create a branch and copy the template:

```bash
git checkout main && git pull
git checkout -b dataset/<CODE>
cp -r dataset/_template dataset/<CODE>
```

---

## Workflow

### 1. Metadata

- Add the dataset citation (paper, report, or DOI) to `reference.bib`.
- In `README.qmd`, update the YAML header (title, author, citation key).
- Briefly describe the dataset: scope, sampling design, and raw input files.

### 2. Soil lab data

OSSL soil property names follow the pattern `<abbrev>_<method>_<unit>`. For example:

| Property | OSSL name |
|---|---|
| Total carbon | `c.tot_usda.a622_w.pct` |
| Organic carbon | `oc_usda.c729_w.pct` |
| pH in water | `ph.h2o_usda.a268_index` |
| Clay (pipette) | `clay.tot_usda.a334_w.pct` |

To build the mapping:

1. Run the `soil_template` chunk once. It writes all raw column names to `soillab_original_names.csv`.
2. Fill one row per property in `soillab_standardized_names.csv`. Take valid codes from [`out/ossl_level0_names_soillab.csv`](out/ossl_level0_names_soillab.csv).

| Column | Meaning |
|---|---|
| `table` | Source file or sheet |
| `original_name` | Column name in the source |
| `import` | `TRUE` to import; otherwise skipped |
| `original_unit`, `original_method` | As reported in the source |
| `comment` | Notes on conversions or exclusions |
| `ossl_abbrev`, `ossl_method`, `ossl_unit` | OSSL codes |
| `ossl_convert` | R expression applied to `x` |
| `ossl_name` | `{abbrev}_{method}_{unit}` |

Common `ossl_convert` expressions (negative values become `NA`):

| Conversion | Expression |
|---|---|
| None | `ifelse(as.numeric(x) < 0, NA, as.numeric(x))` |
| g/kg → wt% | `ifelse(as.numeric(x) < 0, NA, as.numeric(x) / 10)` |
| mg/kg → g/kg | `ifelse(as.numeric(x) < 0, NA, as.numeric(x) / 1000)` |

If the team mapping lives in the shared Google Sheet (`OSSL_v2_tab2_soildata_importing`):

- Work in a tab named after the dataset, not in `TEMP`.
- Build `ossl_name` with `=IF(C2=TRUE, G2&"_"&H2&"_"&I2, "")`.
- Download the tab to `dataset/<CODE>/soillab_standardized_names.csv`.

### 3. Site data

| Field | Rule |
|---|---|
| `id.layer_local_c` | Sample ID, stored as character |
| `latitude.point_wgs84_dd` / `longitude.point_wgs84_dd` | WGS84 decimal degrees |
| `layer.upper.depth_usda_cm` / `layer.lower.depth_usda_cm` | Depths in cm |
| `layer.sequence_usda_uint16` | `1` for the surface layer, then `2`, `3`, … |

Add the dataset code and a unique layer ID:

```r
dataset.sitedata <- dataset.sitedata %>%
  mutate(dataset.code_ascii_txt = dataset_code,
         id.layer_uuid_txt = openssl::md5(paste0(dataset.code_ascii_txt, id.layer_local_c)),
         .before = 1)
```

### 4. Spectra

1. Resample the spectra to the OSSL grid with `prospectr::resample`.
2. Run the QC checks and review the results:
   - share of `NA` values
   - share of scans with values `< -1` for MIR absorbance or `< 0` for VNIR/NIR reflectance.
   - share of scans with values `> 5` for MIR absorbance or `> 1` for VNIR/NIR reflectance.
3. Name the columns `scan_mir.<wn>_abs` (MIR) or `scan_visnir.<nm>_ref` (VisNIR).

### 5. Export and check

- Write every table as both `.csv.gz` and `.parquet`: `ossl_soilsite_v1.3`, `ossl_soillab_v1.3`, `ossl_mir_v1.3`, `ossl_visnir_v1.3`.
- Join soil lab data to spectra on `id.layer_local_c`. Confirm there are no unexpected duplicates.
- Look at the spectral preview plot to confirm sensible baselines and absorption features.

### 6. Render and open a pull request

```bash
quarto render dataset/<CODE>/README.qmd --to gfm
git add dataset/<CODE>/
git commit -m "add <CODE> import pipeline"
git push origin dataset/<CODE>
```

Only these files belong in the commit: `README.qmd`, `README.md`, `README_files/`, `reference.bib`, and the two `soillab_*.csv` files. Open the pull request against `main`.

---

## Checklist

- [ ] `dataset/<CODE>/` created from the template; citation added to `reference.bib`
- [ ] `soillab_standardized_names.csv` uses valid Level 0 codes; `ossl_convert` handles negative and missing values
- [ ] Coordinates are in WGS84 and within bounds; depths and layer sequence are set
- [ ] `id.layer_uuid_txt` generated with `openssl::md5()`
- [ ] Spectra resampled to the OSSL grid; QC checks reviewed
- [ ] Exports written as `.csv.gz` and `.parquet`
- [ ] `README.md` renders without errors
- [ ] No raw data or credentials committed
