# Hungarian dataset preparation for the OSSL
Ran Zhi, Jose L. Safanelli, Jonathan Sanderman
— 20 February, 2026.

- [The HSDOS original data](#the-hsdos-original-data)
- [Data standardization to the OSSL
  format](#data-standardization-to-the-ossl-format)

Code repository for preparing and importing the Hungarian Soil
Degradation Observation System (HSDOS) dataset into the Open Soil
Spectral Library.

Project: [Soil Spectroscopy for Global
Good](https://soilspectroscopy.org)  
Development: <https://github.com/soilspectroscopy>  
Last update: 2026-02-20  
Additional documentation:

## The HSDOS original data

Site data, Soil lab data, and Visible Near-Infrared (Vis-NIR) data from
the Hungarian Soil Degradation Observation System (HSDOS). Further
information of the dataset can be found in detail at Mészáros et al.
([2025](#ref-meszaros_vis-nir_2025)).

Original files:  
- `HSDOS_SSL_ver1.1.csv`: csv file with site information, soil
information, and Vis-NIR spectral data.

Directory/folder path with original files (not uploaded to GitHub).

``` r
dir = "/Users/rzhi/Projects/git/ossl-imports-internal/dataset/Hungarian"
# dir = "~/projects/mnt-ossl/import/dataset/BESB"
tic()
```

## Data standardization to the OSSL format

### Site information

``` r
hsdos.metadata <- fread(path(dir, "HSDOS_SSL_ver1.1.csv"), header = T)

hsdos.sitedata <- hsdos.metadata %>%
  select(SAMPLE_TDR_ID, SAMPLING_DATE, LON_WGS84, LAT_WGS84, PROFILE_LEVEL) %>%
  rename(id.layer_local_c = SAMPLE_TDR_ID,
         longitude.point_wgs84_dd = LON_WGS84,
         latitude.point_wgs84_dd = LAT_WGS84) %>%
  mutate(
    layer.upper.depth_usda_cm = case_when(
      PROFILE_LEVEL == 1 ~ 0,
      PROFILE_LEVEL == 2 ~ 30,
      PROFILE_LEVEL == 3 ~ 60,
      TRUE ~ NA_real_
    ),
    layer.lower.depth_usda_cm = case_when(
      PROFILE_LEVEL == 1 ~ 30,
      PROFILE_LEVEL == 2 ~ 60,
      PROFILE_LEVEL == 3 ~ 90,
      TRUE ~ NA_real_
    ),
    layer.sequence_usda_uint16 = as.integer(PROFILE_LEVEL)
  ) %>%
  mutate(id.project_ascii_txt = "Hungarian Soil Degradation Observation System",
         dataset.code_ascii_txt = "HSDOS.SSL",
         observation.ogc.schema.title_ogc_txt = "Open Soil Spectroscopy Library",
         observation.ogc.schema_idn_url = "https://soilspectroscopy.github.io",
         dataset.title_utf8_txt = "HSDOS: Hungarian Soil Degradation Observation System Dataset",
         dataset.owner_utf8_txt = "Open access funding provided by HUN-REN Centre for Agricultural Research",
         dataset.doi_idf_url = "https://zenodo.org/records/13955229",
         dataset.license.title_ascii_txt = "CC-BY",
         dataset.license.address_idn_url = "https://creativecommons.org/licenses/by/4.0/legalcode",
         dataset.contact.name_utf8_txt = "János Mészáros",
         dataset.contact_ietf_email = "koos.sandor@atk.hun-ren.hu") %>%
  mutate(id.layer_uuid_txt = openssl::md5(paste0(dataset.code_ascii_txt, id.layer_local_c)),
         id.location_olc_txt = olctools::encode_olc(latitude.point_wgs84_dd, longitude.point_wgs84_dd, 10),
         .after = id.project_ascii_txt) %>%
  mutate_at(vars(starts_with("id.")), as.character)

# Saving version to dataset root dir
site.qs = path(dir, "ossl_soilsite_v2.0.qs")
qs::qsave(hsdos.sitedata, site.qs, preset = "high")
```

### Soil lab information (reference analytical data)

NOTE: The code chunk below must be run just once for getting a template
for scripted column standardization. Just run once for getting the
original names of soil properties, descriptions, data types, and units.
Then upload to Google Sheet for editing and manually defining the rules
for integrating with the OSSL. Requires Google authentication. A copy of
the output file is saved to this folder for archiving purposes.

**Always leave the sheet name as TEMP to avoid overwritting, then rename
online to download locally.**

``` r
# Getting soillab original variables

soillab.names <- hsdos.metadata %>%
  select(SAMPLE_TDR_ID, pH_KCl, SOM, CaCO3, TSC, TN, P2O5_AL, K2O_AL, PLI) %>%
  rename(id.layer_local_c = SAMPLE_TDR_ID) %>%
  names() %>%
  tibble(original_name = .) %>%
  dplyr::mutate(table = 'HSDOS_SSL_ver1.1.csv', .before = 1) %>%
  dplyr::mutate(import = '', comment = '', ossl_abbrev = '', ossl_method = '', ossl_unit = '',
                ossl_convert = '', ossl_name = '', .after = original_name)

readr::write_csv(soillab.names, path(getwd(), "soillab_original_names.csv"))

# Uploading to google sheet

# Drive 'Open Soil Spectral Library'
# Folder 'Database v2'
googledrive::drive_ls(as_id("1l9VM4fFks2xBloDE69EFTfPgQeFx5aGw"))

# Use the ID of the file 'OSSL_v2_tab2_soildata_importing'
OSSL.soildata.importing <- "1mWTDJDuMp4oObcCxAy9gofSkrkcSWWf1TtEW2SuC1es"

# Checking metadata
googlesheets4::as_sheets_id(OSSL.soildata.importing)

# Checking readme
googlesheets4::read_sheet(OSSL.soildata.importing, sheet = 'readme')

# Preparing soillab.names for this dataset
upload <- dplyr::as_tibble(soillab.names)

# Uploading with TEMP name. Check online, move to sequence, and update name
googlesheets4::write_sheet(upload, ss = OSSL.soildata.importing, sheet = "TEMP")

# Checking metadata
googlesheets4::as_sheets_id(OSSL.soildata.importing)
```

NOTE: The code chunk below must be run just once. Run for getting the
column standardization rules after editing online on Google Sheets. A
copy of the output file is saved to this folder for archiving purposes.

``` r
# Downloading from google sheet

# Checking metadata
googlesheets4::as_sheets_id("1mWTDJDuMp4oObcCxAy9gofSkrkcSWWf1TtEW2SuC1es")

# Preparing soillab.names
transvalues <- googlesheets4::read_sheet("1mWTDJDuMp4oObcCxAy9gofSkrkcSWWf1TtEW2SuC1es",
                                         sheet = "Hungarian") %>%
  filter(import == TRUE) %>%
  select(contains(c("table", "id", "original_name", "original_unit" , "ossl_")))

# Saving to folder
write_csv(transvalues, path(getwd(), "soillab_standardized_names.csv"))
```

Reading standardization rules:

``` r
transvalues <- read_csv(path(getwd(), "soillab_standardized_names.csv"),
                        show_col_types = F)
knitr::kable(transvalues)
```

| table | original_name | original_unit | ossl_abbrev | ossl_method | ossl_unit | ossl_convert | ossl_name |
|:---|:---|:---|:---|:---|:---|:---|:---|
| HSDOS_SSL_ver1.1.csv | pH_KCl | NA | NA | NA | NA | NA | NA |
| HSDOS_SSL_ver1.1.csv | TN | mg/kg | n.tot | iso.11261 | w.pct | ifelse(as.numeric(x) \< 0, NA, as.numeric(x) / 10000) | n.tot_iso.11261_w.pct |

Standardizing soil data to the OSSL format:

``` r
hsdos.reference <- hsdos.metadata

# Harmonization of names and units

valid_mappings <- transvalues %>%
  filter(table == "HSDOS_SSL_ver1.1.csv") %>%
  filter(!is.na(ossl_name) & ossl_name != "") 

analytes.old.names <- valid_mappings %>% pull(original_name)
analytes.new.names <- valid_mappings %>% pull(ossl_name)

analytes.old.names.clean <- analytes.old.names[analytes.old.names != "SAMPLE_TDR_ID"]
analytes.new.names.clean <- analytes.new.names[analytes.old.names != "SAMPLE_TDR_ID"]

hsdos.soildata <- hsdos.reference %>%
  rename(id.layer_local_c = SAMPLE_TDR_ID) %>%
  select(id.layer_local_c, all_of(analytes.old.names.clean)) %>%
  rename_with(~analytes.new.names.clean, all_of(analytes.old.names.clean)) %>%
  mutate(id.layer_local_c = as.character(id.layer_local_c)) %>%
  as.data.frame()

# Getting the formulas
functions.list <- transvalues %>%
  filter(table == "HSDOS_SSL_ver1.1.csv") %>%
  mutate(ossl_name = factor(ossl_name, levels = names(hsdos.soildata))) %>%
  arrange(ossl_name) %>%
  pull(ossl_convert) %>%
  c("x", .)

# Applying transformation rules
hsdos.soildata.trans <- transform_values(df = hsdos.soildata,
                                       out.name = names(hsdos.soildata),
                                       in.name = names(hsdos.soildata),
                                       fun.lst = functions.list)

# Final soillab data
hsdos.soildata <- hsdos.soildata.trans %>%
  mutate_at(vars(starts_with("id.")), as.character)

# Checking total number of observations
hsdos.soildata %>%
  distinct(id.layer_local_c) %>%
  summarise(count = n())
```

      count
    1  5490

``` r
# Saving version to dataset root dir
soillab.qs = path(dir, "ossl_soillab_v2.0.qs")
qs::qsave(hsdos.soildata, soillab.qs, preset = "high")
```

<div id="refs" class="references csl-bib-body hanging-indent"
entry-spacing="0" line-spacing="2">

<div id="ref-meszaros_vis-nir_2025" class="csl-entry">

Mészáros, J., Kovács, Z., László, P., Vass-Meyndt, S., Koós, S., Pirkó,
B., … Pásztor, L. (2025). Vis-NIR soil spectral library of the Hungarian
Soil Degradation Observation System. *Scientific Data*, *12*(1), 363.
doi:[10.1038/s41597-025-04667-9](https://doi.org/10.1038/s41597-025-04667-9)

</div>

</div>
