
## Table of Contents

- [Core Principles](#core-principles)
- [Repository Structure](#repository-structure)
- [Prerequisites & Setup](#prerequisites--setup)
- [Step-by-Step Dataset Contribution Guide](#step-by-step-dataset-contribution-guide)
  - [Phase 1: Choose Dataset Code & Initialize Folder](#phase-1-choose-dataset-code--initialize-folder)
  - [Phase 2: Metadata & Bibliography](#phase-2-metadata--bibliography)
  - [Phase 3: Soil Lab Standardization Table](#phase-3-soil-lab-standardization-table)
  - [Phase 4: Site Information Standardization](#phase-4-site-information-standardization)
  - [Phase 5: Spectral Data Resampling & Quality Control](#phase-5-spectral-data-resampling--quality-control)
  - [Phase 6: Quality Verification & Cross-Table Consistency](#phase-6-quality-verification--cross-table-consistency)
  - [Phase 7: Rendering & Pull Request](#phase-7-rendering--pull-request)
- [Standardization Schema Reference](#standardization-schema-reference)
- [Collaborative Google Sheet Workflow](#collaborative-google-sheet-workflow)
- [Contribution Checklist](#contribution-checklist)

---

## Core Principles

1. **Reproducibility**: Every dataset is documented and processed via an executable Quarto document (`README.qmd`) that renders to a GitHub-compatible `README.md`.
2. **Separation of Raw Data & Code**: Raw data files (often large or under varying licenses) are kept in private/cloud storage (`~/mnt-ossl-private/database/datasets/<DATASET_CODE>/`) and are **never** committed to Git.
3. **Controlled Vocabularies**: All variable names, analytical methods, and measurement units must strictly follow OSSL Level 0 standards (documented in `out/`).
4. **Spectral Consistency**: All spectra are resampled onto standard grids:
   - **MIR**: 600 to 4000 cm⁻¹ at 2 cm⁻¹ intervals (`scan_mir.XXXX_abs`).
   - **VisNIR**: 350 to 2500 nm at 2 nm intervals (`scan_visnir.XXXX_ref`).

---

## Repository Structure

```text
ossl-imports/
├── dataset/
│   ├── _template/                 # Canonical starter pack for new datasets
│   │   ├── README.qmd             # Quarto pipeline template
│   │   ├── reference.bib          # Bibliography template
│   │   ├── soillab_original_names.csv      # Empty header template
│   │   └── soillab_standardized_names.csv  # Example mapping rules
│   ├── AFSIS1/
│   ├── AUT/
│   ├── CAF/
│   └── <YOUR_DATASET>/            # Your new dataset folder
├── out/                           # Controlled vocabularies & Level 0 schemas
│   ├── ossl_level0_names_soilsite.csv
│   ├── ossl_level0_names_soillab.csv
│   ├── ossl_level0_names_mir.csv
│   └── ossl_level0_names_visnir.csv
├── R/
│   └── functions/
│       └── SSL_functions.R        # Shared utility functions (transform_values, etc.)
├── tex/                           # Bibliography styles and shared references
└── CONTRIBUTING.md                # This guide
```

---

## Prerequisites & Setup

1. **R (>= 4.2)** and **Quarto CLI (>= 1.3)** installed.
2. Required R packages:
   ```r
   install.packages(c(
     "tidyverse", "data.table", "lubridate", "units", "readxl",
     "stringr", "tmap", "sf", "rnaturalearth", "skimr",
     "prospectr", "tictoc", "nanoparquet", "fs", "openssl"
   ))
   ```
3. Create a feature branch for your dataset:
   ```bash
   git checkout -b dataset/<DATASET_CODE>
   ```

---

## Step-by-Step Dataset Contribution Guide

### Phase 1: Choose Dataset Code & Initialize Folder

1. Select a unique, concise dataset abbreviation (3–8 uppercase alphanumeric characters, e.g., `CAF`, `AUT`, `BESB`, `KSSL`).
2. Copy `dataset/_template/` to `dataset/<DATASET_CODE>/`:
   ```bash
   cp -r dataset/_template dataset/<DATASET_CODE>
   ```

### Phase 2: Metadata & Bibliography

1. Open `dataset/<DATASET_CODE>/reference.bib` and add the BibTeX citation for the dataset paper, report, or data repository DOI.
2. In `dataset/<DATASET_CODE>/README.qmd`:
   - Update YAML metadata (`title`, `author`, `email`, citation key in `@...`).
   - Describe the dataset background, geographic scope, sampling strategy, and list the raw input filenames.

---

### Phase 3: Soil Lab Standardization Table

The OSSL standardizes all wet chemistry / reference properties using a 3-part naming convention:
$$\text{ossl\_name} = \text{ossl\_abbrev}\_\text{ossl\_method}\_\text{ossl\_unit}$$

Examples:
- Total Carbon: `c.tot_usda.a622_w.pct`
- Organic Carbon: `oc_usda.c729_w.pct`
- Water pH: `ph.h2o_usda.a268_index`
- Pipette Clay: `clay.tot_usda.a334_w.pct`

#### The Standardization Table Schema (`soillab_standardized_names.csv`)

| Column Name | Type | Description | Example |
| :--- | :--- | :--- | :--- |
| `table` | Character | Source filename or sheet name | `raw_lab_data.csv` |
| `original_name` | Character | Column name in the source file | `Total_C_pct` |
| `import` | Logical | Set `TRUE` to import into OSSL; `NA` or `FALSE` to skip | `TRUE` |
| `original_unit` | Character | Original measurement unit in source | `g/kg` |
| `original_method`| Character | Analytical method reported in source | `Dry combustion (ISO 10694)` |
| `comment` | Character | Notes on conversions or exclusions | `Converted from g/kg to wt%` |
| `ossl_abbrev` | Character | Standard OSSL property code (from `out/ossl_level0_names_soillab.csv`) | `c.tot` |
| `ossl_method` | Character | Standard OSSL method code (from `out/ossl_level0_names_soillab.csv`) | `usda.a622` |
| `ossl_unit` | Character | Standard OSSL target unit (from `out/ossl_level0_names_soillab.csv`) | `w.pct` |
| `ossl_convert` | Character | Valid R expression to transform values | `"ifelse(as.numeric(x) < 0, NA, as.numeric(x)/10)"` |
| `ossl_name` | Character | Full target column name (`{abbrev}_{method}_{unit}`) | `c.tot_usda.a622_w.pct` |

#### How to fill the table:
1. Run the `soil_template` chunk in `README.qmd` once (`eval=FALSE`) to dump all original column names to `soillab_original_names.csv`.
2. Map the properties into `soillab_standardized_names.csv`. Refer to [`out/ossl_level0_names_soillab.csv`](file:///Users/jsafanelli/projects/git/ossl-imports/out/ossl_level0_names_soillab.csv) for valid OSSL property codes and units.
3. Define the conversion expression in `ossl_convert`:
   - No conversion needed: `"ifelse(as.numeric(x) < 0, NA, as.numeric(x) * 1)"`
   - g/kg to weight percent (wt%): `"ifelse(as.numeric(x) < 0, NA, as.numeric(x) / 10)"`
   - mg/kg to g/kg: `"ifelse(as.numeric(x) < 0, NA, as.numeric(x) / 1000)"`

---

### Phase 4: Site Information Standardization

In `README.qmd`, under the `### Site information` chunk:
1. Map raw sample identifiers to `id.layer_local_c` (must be character string).
2. Standardize latitude and longitude to WGS84 decimal degrees:
   - `latitude.point_wgs84_dd` (range: -90 to +90)
   - `longitude.point_wgs84_dd` (range: -180 to +180)
3. Standardize depth intervals:
   - `layer.upper.depth_usda_cm` (top depth, e.g. `0`)
   - `layer.lower.depth_usda_cm` (bottom depth, e.g. `20`)
   - `layer.sequence_usda_uint16` (`1` for surface layer, `2+` for subsequent depths)
4. Calculate unique layer UUID:
   ```r
   dataset.sitedata <- dataset.sitedata %>%
     mutate(dataset.code_ascii_txt = dataset_code,
            id.layer_uuid_txt = openssl::md5(paste0(dataset.code_ascii_txt, id.layer_local_c)),
            .before = 1)
   ```
5. Export both compressed CSV and Parquet:
   ```r
   readr::write_csv(dataset.sitedata, path(dir, "ossl_soilsite_v1.3.csv.gz"))
   nanoparquet::write_parquet(dataset.sitedata, path(dir, "ossl_soilsite_v1.3.parquet"))
   ```

---

### Phase 5: Spectral Data Resampling & Quality Control

In `README.qmd`, under `### Spectral data`:
1. Resample spectra onto the standard grid using spline interpolation (`prospectr::resample`):
   - **MIR**: 600 to 4000 cm⁻¹ at step 2 cm⁻¹.
   - **VisNIR**: 350 to 2500 nm at step 2 nm.
2. Run standard OSSL Quality Control checks:
   - **Proportion of NAs**: Check for missing spectral gaps.
   - **Extreme negative values**: Proportion of scans with values `< -1`.
   - **Extreme positive values**: Proportion of scans with values `> 5`.
3. Rename columns using standard syntax:
   - MIR: `scan_mir.600_abs`, ..., `scan_mir.4000_abs`
   - VisNIR: `scan_visnir.350_ref`, ..., `scan_visnir.2500_ref`
4. Export:
   - `ossl_mir_v1.3.csv.gz` / `.parquet`
   - `ossl_visnir_v1.3.csv.gz` / `.parquet`

---

### Phase 6: Quality Verification & Cross-Table Consistency

In the final chunks of `README.qmd`:
1. Perform a `left_join` of soil lab data to spectral data using `id.layer_local_c`.
2. Verify that there are no unexpected duplicates on `id.layer_local_c`.
3. Inspect the spectral preview plot to confirm sensible baselines and absorption features.

---

### Phase 7: Rendering & Pull Request

1. Render the Quarto document to GitHub Flavored Markdown:
   ```bash
   quarto render dataset/<DATASET_CODE>/README.qmd --to gfm
   ```
2. Check `git status` to ensure only the necessary files are tracked:
   - `dataset/<DATASET_CODE>/README.qmd`
   - `dataset/<DATASET_CODE>/README.md`
   - `dataset/<DATASET_CODE>/README_files/`
   - `dataset/<DATASET_CODE>/reference.bib`
   - `dataset/<DATASET_CODE>/soillab_original_names.csv`
   - `dataset/<DATASET_CODE>/soillab_standardized_names.csv`
3. Commit and push:
   ```bash
   git add dataset/<DATASET_CODE>/
   git commit -m "feat(dataset): add <DATASET_CODE> import pipeline"
   git push origin dataset/<DATASET_CODE>
   ```
4. Open a Pull Request against the main repository.

---

## Standardization Schema Reference

Before naming columns, inspect the schema tables located in [`out/`](file:///Users/jsafanelli/projects/git/ossl-imports/out/):

- [`out/ossl_level0_names_soilsite.csv`](file:///Users/jsafanelli/projects/git/ossl-imports/out/ossl_level0_names_soilsite.csv): Site, location, date, profile, and administrative fields.
- [`out/ossl_level0_names_soillab.csv`](file:///Users/jsafanelli/projects/git/ossl-imports/out/ossl_level0_names_soillab.csv): Reference soil analytes, allowable abbreviations, methods, and units.
- [`out/ossl_level0_names_mir.csv`](file:///Users/jsafanelli/projects/git/ossl-imports/out/ossl_level0_names_mir.csv): MIR metadata and spectral range.
- [`out/ossl_level0_names_visnir.csv`](file:///Users/jsafanelli/projects/git/ossl-imports/out/ossl_level0_names_visnir.csv): VisNIR metadata and spectral range.

---

## Collaborative Google Sheet Workflow

For team members using the central Google Sheet (`OSSL_v2_tab2_soildata_importing`):

1. **Avoid the `"TEMP"` tab**: Create a dedicated tab named after the dataset (e.g. `CAF`, `AUT`).
2. **Formula Auto-Fill**: In Google Sheets, set the formula for `ossl_name` to:
   ```excel
   =IF(C2=TRUE, CONCATENATE(G2, "_", H2, "_", I2), "")
   ```
3. **Data Validation**: Ensure `ossl_abbrev`, `ossl_method`, and `ossl_unit` use dropdown validation referencing the master vocabulary.
4. Once finalized online, export or download the sheet directly to `dataset/<DATASET_CODE>/soillab_standardized_names.csv`.

---

## Contribution Checklist

- [ ] Dataset folder named using uppercase abbreviation (`dataset/<DATASET_CODE>/`).
- [ ] Source citation added to `reference.bib`.
- [ ] `soillab_standardized_names.csv` filled with valid OSSL Level 0 abbreviations, methods, and units.
- [ ] `ossl_convert` formulas tested and handle negative or missing values.
- [ ] All coordinates in WGS84 decimal degrees and within valid bounds.
- [ ] USDA depth sequence and layer numbers properly derived.
- [ ] Unique `id.layer_uuid_txt` generated using `openssl::md5()`.
- [ ] Spectra resampled to OSSL grid (MIR: 600–4000 cm⁻¹ by 2; VisNIR: 350–2500 nm by 2).
- [ ] Spectral QC checks (NA %, extreme values) executed and reviewed.
- [ ] Export files generated (`.csv.gz` and `.parquet`) in the dataset export directory.
- [ ] Quarto rendered successfully to `README.md`.
- [ ] **No raw dataset files or Google credentials committed to Git**.
