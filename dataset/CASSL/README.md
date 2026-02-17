# CASSL dataset preparation for the OSSL
Jose L. Safanelli, Ran Zhi, Tomislav Hengl, Jonathan Sanderman
— 17 February, 2026.

- [The CASSL original data](#the-cassl-original-data)
- [Data standardization to the OSSL
  format](#data-standardization-to-the-ossl-format)
- [Quality control](#quality-control)
- [References](#references)

Code repository for preparing and importing the Central African Soil
Spectral Library (CASSL) dataset into the Open Soil Spectral Library.

Project: [Soil Spectroscopy for Global
Good](https://soilspectroscopy.org)  
Development: <https://github.com/soilspectroscopy>  
Last update: 2026-02-17  
Additional documentation:
[CAF.SSL](https://docs.soilspectroscopy.org/soilspec.html#caf.ssl)

## The CASSL original data

Site data, Soil lab data, and Mid-Infrared Spectra (MIR) from the
Central African Soil Spectral Library (CASSL). Further information of
the dataset can be found in detail at Summerauer et al.
([2021](#ref-summerauer2021central)).

A copy of the dataset can be obtained from
<https://github.com/laura-summerauer/ssl-central-africa>.

Original files:  
- `cssl_metadata_all.csv`: csv file with site information;  
- `ssl_refdata_all.csv`: csv file with soil information;  
- `cssl_spectra.csv`: csv with MIR spectral scans;

Directory/folder path with original files (not uploaded to GitHub).

``` r
# dir = "./"
dir = "~/projects/mnt-ossl/import/dataset/CASSL"
tic()
```

## Data standardization to the OSSL format

### Site information

``` r
caf.metadata <- fread(path(dir, "cssl_metadata_all.csv"), header = T)

caf.sitedata <- caf.metadata %>%
  select(sample_id, sample_location, country_code,
         sampling_date, sampling_layer, gps_long, gps_lat, gps_true) %>%
  rename(id.layer_local_c = sample_id,
         longitude.point_wgs84_dd = gps_long,
         latitude.point_wgs84_dd = gps_lat) %>%
  mutate(id.layer_local_c = as.character(id.layer_local_c)) %>%
  filter(lengths(str_split(sampling_layer, "-")) == 2) %>%
  separate(sampling_layer, into = c("layer.upper.depth_usda_cm", "layer.lower.depth_usda_cm"), sep = "-") %>%
  mutate(layer.sequence_usda_uint16 = ifelse(layer.upper.depth_usda_cm == 0, 1, 2),
         location.point.error_any_m = ifelse(gps_true == "yes", 30, 1000)) %>%
  mutate(sampling_date = gsub("/", "-", sampling_date)) %>%
  mutate(sampling_date = case_when(is.na(sampling_date) ~ NA_character_,
                                   str_count(sampling_date, "-") == 2 ~ sampling_date,
                                   str_count(sampling_date, "-") == 1 &
                                     str_length(sampling_date) == 7 ~ paste0(sampling_date, "-01"),
                                   str_count(sampling_date, "-") == 1 &
                                     str_length(sampling_date) > 7 ~ paste0(str_sub(sampling_date, 1, 4), "-01-01"),
                                   str_count(sampling_date, "-") == 0 &
                                     str_length(sampling_date) == 4 ~paste0(str_sub(sampling_date, 1, 4), "-01-01"),
                                   TRUE ~ NA_character_), .after = sampling_date) %>%
  rename(observation.date.begin_iso.8601_yyyy.mm.dd = sampling_date) %>%
  mutate(observation.date.end_iso.8601_yyyy.mm.dd = observation.date.begin_iso.8601_yyyy.mm.dd) %>%
  select(id.layer_local_c, longitude.point_wgs84_dd, latitude.point_wgs84_dd, location.point.error_any_m,
         layer.sequence_usda_uint16, layer.upper.depth_usda_cm, layer.lower.depth_usda_cm,
         observation.date.begin_iso.8601_yyyy.mm.dd, observation.date.end_iso.8601_yyyy.mm.dd) %>%
  mutate(id.project_ascii_txt = "The Central African Soil Spectral Library",
         layer.texture_usda_txt = "",
         pedon.taxa_usda_txt = "",
         horizon.designation_usda_txt = "",
         longitude.county_wgs84_dd = NA,
         latitude.county_wgs84_dd = NA,
         location.country_iso.3166_txt = "",
         observation.ogc.schema.title_ogc_txt = "Open Soil Spectroscopy Library",
         observation.ogc.schema_idn_url = "https://soilspectroscopy.github.io",
         surveyor.title_utf8_txt = "Department of Environmental Systems Science, ETH Zurich, Zurich Switzerland",
         surveyor.contact_ietf_email = "laura.summerauer@usys.ethz.ch",
         surveyor.address_utf8_txt = "Department of Environmental Systems Science, ETH Zurich, Zurich Switzerland",
         dataset.title_utf8_txt = "The Central African Soil Spectral Library",
         dataset.owner_utf8_txt = "ETH Zurich",
         dataset.code_ascii_txt = "CAF.SSL",
         dataset.address_idn_url = "https://www.isric.org/explore/ISRIC-collections",
         dataset.doi_idf_url = "https://doi.org/10.5281/zenodo.4351254",
         dataset.license.title_ascii_txt = "CC-BY",
         dataset.license.address_idn_url = "https://creativecommons.org/licenses/by/4.0/",
         dataset.contact.name_utf8_txt = "Laura Summerauer",
         dataset.contact_ietf_email = "laura.summerauer@usys.ethz.ch") %>%
  mutate(id.layer_uuid_txt = openssl::md5(paste0(dataset.code_ascii_txt, id.layer_local_c)),
         id.location_olc_txt = olctools::encode_olc(latitude.point_wgs84_dd, longitude.point_wgs84_dd, 10),
         .after = id.project_ascii_txt) %>%
  mutate_at(vars(starts_with("id.")), as.character)

# Saving version to dataset root dir
site.qs = path(dir, "ossl_soilsite_v2.0.qs")
qs::qsave(caf.sitedata, site.qs, preset = "high")
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

cassl.soildata <- fread(path(dir, "ssl_refdata_all.csv"), header = T)

soillab.names <- cassl.soildata %>%
  names(.) %>%
  tibble(original_name = .) %>%
  dplyr::mutate(table = 'ssl_refdata_all', .before = 1) %>%
  dplyr::mutate(import = '', ossl_name = '', .after = original_name) %>%
  dplyr::mutate(comment = '')

readr::write_csv(soillab.names, paste0(getwd(), "/soillab_original_names.csv"))

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
                                         sheet = "CAF") %>%
  filter(import == TRUE) %>%
  select(contains(c("table", "id", "original_name", "ossl_")))

# Saving to folder
write_csv(transvalues, path(getwd(), "soillab_standardized_names.csv"))
```

Reading standardization rules:

``` r
transvalues <- read_csv(path(getwd(), "soillab_standardized_names.csv"),
                        show_col_types = F)
knitr::kable(transvalues)
```

| table            | original_name   | ossl_abbrev | ossl_method | ossl_unit | ossl_convert                                     | ossl_name                |
|:-----------------|:----------------|:------------|:------------|:----------|:-------------------------------------------------|:-------------------------|
| cssl_refdata_all | tc              | c.tot       | usda.a622   | w.pct     | ifelse(as.numeric(x) \< 0, NA, as.numeric(x)/10) | c.tot_usda.a622_w.pct    |
| cssl_refdata_all | tn              | n.tot       | usda.a623   | w.pct     | ifelse(as.numeric(x) \< 0, NA, as.numeric(x)/10) | n.tot_usda.a623_w.pct    |
| cssl_refdata_all | ph_h2o          | ph.h2o      | usda.a268   | index     | ifelse(as.numeric(x) \< 0, NA, as.numeric(x)\*1) | ph.h2o_usda.a268_index   |
| cssl_refdata_all | ph_cacl2        | ph.cacl2    | usda.a481   | index     | ifelse(as.numeric(x) \< 0, NA, as.numeric(x)\*1) | ph.cacl2_usda.a481_index |
| cssl_refdata_all | clay_0-0.002    | clay.tot    | usda.a334   | w.pct     | ifelse(as.numeric(x) \< 0, NA, as.numeric(x)\*1) | clay.tot_usda.a334_w.pct |
| cssl_refdata_all | silt_0.002-0.05 | silt.tot    | usda.c62    | w.pct     | ifelse(as.numeric(x) \< 0, NA, as.numeric(x)\*1) | silt.tot_usda.c62_w.pct  |
| cssl_refdata_all | sand_0.05-2     | sand.tot    | usda.c60    | w.pct     | ifelse(as.numeric(x) \< 0, NA, as.numeric(x)\*1) | sand.tot_usda.c60_w.pct  |
| cssl_refdata_all | al_icp          | al.ext      | aquaregia   | g.kg      | ifelse(as.numeric(x) \< 0, NA, as.numeric(x)\*1) | al.ext_aquaregia_g.kg    |
| cssl_refdata_all | fe_icp          | fe.ext      | aquaregia   | g.kg      | ifelse(as.numeric(x) \< 0, NA, as.numeric(x)\*1) | fe.ext_aquaregia_g.kg    |
| cssl_refdata_all | ca_icp          | ca.ext      | aquaregia   | mg.kg     | ifelse(as.numeric(x) \< 0, NA, as.numeric(x)\*1) | ca.ext_aquaregia_mg.kg   |
| cssl_refdata_all | mg_icp          | mg.ext      | aquaregia   | mg.kg     | ifelse(as.numeric(x) \< 0, NA, as.numeric(x)\*1) | mg.ext_aquaregia_mg.kg   |
| cssl_refdata_all | k_icp           | k.ext       | aquaregia   | mg.kg     | ifelse(as.numeric(x) \< 0, NA, as.numeric(x)\*1) | k.ext_aquaregia_mg.kg    |
| cssl_refdata_all | mn_icp          | mn.ext      | aquaregia   | mg.kg     | ifelse(as.numeric(x) \< 0, NA, as.numeric(x)\*1) | mn.ext_aquaregia_mg.kg   |
| cssl_refdata_all | na_icp          | na.ext      | aquaregia   | mg.kg     | ifelse(as.numeric(x) \< 0, NA, as.numeric(x)\*1) | na.ext_aquaregia_mg.kg   |
| cssl_refdata_all | p_icp           | p.ext       | aquaregia   | mg.kg     | ifelse(as.numeric(x) \< 0, NA, as.numeric(x)\*1) | p.ext_aquaregia_mg.kg    |

Standardizing soil data to the OSSL format:

``` r
caf.reference <- fread(path(dir, "ssl_refdata_all.csv"),
                       header = T)

# Harmonization of names and units
analytes.old.names <- transvalues %>%
  filter(table == "cssl_refdata_all") %>%
  pull(original_name)

analytes.new.names <- transvalues %>%
  filter(table == "cssl_refdata_all") %>%
  pull(ossl_name)

# Selecting and renaming
caf.soildata <- caf.reference %>%
  rename(id.layer_local_c = sample_id) %>%
  select(id.layer_local_c, all_of(analytes.old.names)) %>%
  rename_with(~analytes.new.names, all_of(analytes.old.names)) %>%
  mutate(id.layer_local_c = as.character(id.layer_local_c)) %>%
  as.data.frame()

# Removing duplicates
# caf.soildata %>%
#   group_by(id.layer_local_c) %>%
#   summarise(repeats = n()) %>%
#   group_by(repeats) %>%
#   summarise(count = n())

# Getting the formulas
functions.list <- transvalues %>%
  filter(table == "cssl_refdata_all") %>%
  mutate(ossl_name = factor(ossl_name, levels = names(caf.soildata))) %>%
  arrange(ossl_name) %>%
  pull(ossl_convert) %>%
  c("x", .)

# Applying transformation rules
caf.soildata.trans <- transform_values(df = caf.soildata,
                                       out.name = names(caf.soildata),
                                       in.name = names(caf.soildata),
                                       fun.lst = functions.list)

# Final soillab data
caf.soildata <- caf.soildata.trans %>%
  mutate_at(vars(starts_with("id.")), as.character)

# Checking total number of observations
caf.soildata %>%
  distinct(id.layer_local_c) %>%
  summarise(count = n())
```

      count
    1  1852

``` r
# Saving version to dataset root dir
soillab.qs = path(dir, "ossl_soillab_v2.0.qs")
qs::qsave(caf.soildata, soillab.qs, preset = "high")
```

### Mid-infrared spectra

``` r
# Floating wavenumbers
caf.spectra <- fread(path(dir, "cssl_spectra.csv"), header = T)

# Renaming
old.names <- names(caf.spectra)

caf.mir <- caf.spectra %>%
  rename(id.layer_local_c = sample_id) %>%
  mutate(id.layer_local_c = as.character(id.layer_local_c)) %>%
  mutate_at(vars(all_of(old.names[-1])), as.numeric)

# Need to resample spectra
old.wavenumber <- na.omit(as.numeric(names(caf.mir)))
```

    Warning in na.omit(as.numeric(names(caf.mir))): NAs introduced by coercion

``` r
new.wavenumbers <- rev(seq(600, 4000, by = 2))

caf.mir <- caf.mir %>%
  select(-id.layer_local_c) %>%
  as.matrix() %>%
  prospectr::resample(X = ., wav = old.wavenumber, new.wav = new.wavenumbers, interpol = "spline") %>%
  as_tibble() %>%
  bind_cols({caf.mir %>%
      select(id.layer_local_c)}, .) %>%
  select(id.layer_local_c, as.character(rev(new.wavenumbers)))

# Gaps
scans.na.gaps <- caf.mir %>%
  select(-id.layer_local_c) %>%
  apply(., 1, function(x) round(100*(sum(is.na(x)))/(length(x)), 2)) %>%
  tibble(proportion_NA = .) %>%
  bind_cols({caf.mir %>% select(id.layer_local_c)}, .)

# Extreme negative - irreversible erratic patterns
scans.extreme.neg <- caf.mir %>%
  select(-id.layer_local_c) %>%
  apply(., 1, function(x) {round(100*(sum(x < -1, na.rm=TRUE))/(length(x)), 2)}) %>%
  tibble(proportion_lower0 = .) %>%
  bind_cols({caf.mir %>% select(id.layer_local_c)}, .)

# Extreme positive, irreversible erratic patterns
scans.extreme.pos <- caf.mir %>%
  select(-id.layer_local_c) %>%
  apply(., 1, function(x) {round(100*(sum(x > 5, na.rm=TRUE))/(length(x)), 2)}) %>%
  tibble(proportion_higherAbs5 = .) %>%
  bind_cols({caf.mir %>% select(id.layer_local_c)}, .)

# Consistency summary - problematic scans
scans.summary <- scans.na.gaps %>%
  left_join(scans.extreme.neg, by = "id.layer_local_c") %>%
  left_join(scans.extreme.pos, by = "id.layer_local_c")

scans.summary %>%
  select(-id.layer_local_c) %>%
  pivot_longer(everything(), names_to = "check", values_to = "value") %>%
  filter(value > 0) %>%
  group_by(check) %>%
  summarise(count = n())
```

    # A tibble: 0 × 2
    # ℹ 2 variables: check <chr>, count <int>

``` r
# Renaming
old.wavenumbers <- seq(600, 4000, by = 2)
new.wavenumbers <- paste0("scan_mir.", old.wavenumbers, "_abs")

caf.mir <- caf.mir %>%
  rename_with(~new.wavenumbers, as.character(old.wavenumbers))

# Preparing metadata
caf.mir.metadata <- caf.mir %>%
  select(id.layer_local_c) %>%
  mutate(id.scan_local_c = id.layer_local_c) %>%
  mutate(scan.mir.date.begin_iso.8601_yyyy.mm.dd = ymd("2014-01-01"),
         scan.mir.date.end_iso.8601_yyyy.mm.dd = ymd("2018-12-31"),
         scan.mir.model.name_utf8_txt = "Bruker Vertex 70 with HTS-XT accessory",
         scan.mir.model.code_any_txt = "Bruker_Vertex_70.HTS.XT",
         scan.mir.method.optics_any_txt = "",
         scan.mir.method.preparation_any_txt = "",
         scan.mir.license.title_ascii_txt = "CC-BY",
         scan.mir.license.address_idn_url = "https://creativecommons.org/licenses/by/4.0/",
         scan.mir.doi_idf_url = "https://doi.org/10.5281/zenodo.4351254",
         scan.mir.contact.name_utf8_txt = "Laura Summerauer",
         scan.mir.contact.email_ietf_txt = "laura.summerauer@usys.ethz.ch")

# Final preparation
caf.mir.export <- caf.mir.metadata %>%
  left_join(caf.mir, by = "id.layer_local_c") %>%
  mutate_at(vars(starts_with("id.")), as.character)

# Saving version to dataset root dir
soilmir.qs = path(dir, "ossl_mir_v2.0.qs")
qs::qsave(caf.mir.export, soilmir.qs, preset = "high")
```

## Quality control

The final table must be joined as follows:

- MIR is used as first reference for left join.
- Then it is left joined with the site and soil lab data. This drop data
  without any available scan.

The availability of data is summarized below:

``` r
# Taking a few representative columns for checking the consistency of joins
caf.availability <- caf.mir.export %>%
  select(id.layer_local_c, scan_mir.600_abs) %>%
  left_join({caf.sitedata %>%
      select(id.layer_local_c, layer.upper.depth_usda_cm)}, by = "id.layer_local_c") %>%
  left_join({caf.soildata %>%
      select(id.layer_local_c, ph.h2o_usda.a268_index)}, by = "id.layer_local_c") %>%
  filter(!is.na(id.layer_local_c))

# Availability of information from caf
caf.availability %>%
  mutate_all(as.character) %>%
  pivot_longer(everything(), names_to = "column", values_to = "value") %>%
  filter(!is.na(value)) %>%
  group_by(column) %>%
  summarise(count = n())
```

    # A tibble: 4 × 2
      column                    count
      <chr>                     <int>
    1 id.layer_local_c           1578
    2 layer.upper.depth_usda_cm  1520
    3 ph.h2o_usda.a268_index      483
    4 scan_mir.600_abs           1578

``` r
# Repeats check - Duplicates are dropped
caf.availability %>%
  mutate_all(as.character) %>%
  select(id.layer_local_c) %>%
  pivot_longer(everything(), names_to = "column", values_to = "value") %>%
  group_by(column, value) %>%
  summarise(repeats = n()) %>%
  group_by(column, repeats) %>%
  summarise(count = n())
```

    `summarise()` has grouped output by 'column'. You can override using the
    `.groups` argument.
    `summarise()` has grouped output by 'column'. You can override using the
    `.groups` argument.

    # A tibble: 1 × 3
    # Groups:   column [1]
      column           repeats count
      <chr>              <int> <int>
    1 id.layer_local_c       1  1578

Plotting sites map:

``` r
data("World")

points <- caf.sitedata %>%
  filter(!is.na(longitude.point_wgs84_dd)) %>%
  st_as_sf(coords = c('longitude.point_wgs84_dd', 'latitude.point_wgs84_dd'), crs = 4326)

tmap_mode("plot")
```

    ℹ tmap modes "plot" - "view"
    ℹ toggle with `tmap::ttm()`

``` r
tm_shape(World) +
  tm_polygons('#f0f0f0f0', border.alpha = 0.2) +
  tm_shape(points) +
  tm_dots()
```


    ── tmap v3 code detected ───────────────────────────────────────────────────────
    [v3->v4] `tm_polygons()`: use `col_alpha` instead of `border.alpha`.[tip] Consider a suitable map projection, e.g. by adding `+ tm_crs("auto")`.

![](README_files/figure-commonmark/map-1.png)

Soil analytical data summary. Note: many scans could not be linked with
the wetchem.

``` r
caf.soildata %>%
  mutate(id.layer_local_c = factor(id.layer_local_c)) %>%
  skimr::skim() %>%
  dplyr::select(-numeric.hist, -complete_rate)
```

|                                                  |            |
|:-------------------------------------------------|:-----------|
| Name                                             | Piped data |
| Number of rows                                   | 1852       |
| Number of columns                                | 16         |
| \_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_   |            |
| Column type frequency:                           |            |
| factor                                           | 1          |
| logical                                          | 1          |
| numeric                                          | 14         |
| \_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_ |            |
| Group variables                                  | None       |

Data summary

**Variable type: factor**

| skim_variable    | n_missing | ordered | n_unique | top_counts                         |
|:-----------------|----------:|:--------|---------:|:-----------------------------------|
| id.layer_local_c |         0 | FALSE   |     1852 | 08\_: 1, 08\_: 1, 08\_: 1, 08\_: 1 |

**Variable type: logical**

| skim_variable            | n_missing | mean | count |
|:-------------------------|----------:|-----:|:------|
| ph.cacl2_usda.a481_index |      1852 |  NaN | :     |

**Variable type: numeric**

| skim_variable            | n_missing |   mean |      sd |    p0 |    p25 |    p50 |    p75 |     p100 |
|:-------------------------|----------:|-------:|--------:|------:|-------:|-------:|-------:|---------:|
| c.tot_usda.a622_w.pct    |       184 |   1.98 |    2.51 |  0.08 |   0.89 |   1.38 |   2.31 |    45.54 |
| n.tot_usda.a623_w.pct    |       168 |   0.16 |    0.18 |  0.01 |   0.07 |   0.11 |   0.18 |     2.92 |
| ph.h2o_usda.a268_index   |      1317 |   5.10 |    0.94 |  3.32 |   4.51 |   4.84 |   5.36 |     8.56 |
| clay.tot_usda.a334_w.pct |      1262 |  34.63 |   21.73 |  1.04 |  12.41 |  34.88 |  51.59 |    86.88 |
| silt.tot_usda.c62_w.pct  |      1309 |  23.85 |   14.97 |  4.00 |  13.48 |  19.28 |  29.87 |    74.75 |
| sand.tot_usda.c60_w.pct  |      1309 |  42.30 |   23.77 |  1.30 |  21.12 |  40.50 |  61.12 |    89.90 |
| al.ext_aquaregia_g.kg    |      1128 |  25.20 |   24.69 |  0.16 |   7.94 |  12.37 |  36.24 |   121.32 |
| fe.ext_aquaregia_g.kg    |      1128 |  38.84 |   39.55 |  0.34 |  10.15 |  20.13 |  59.62 |   352.66 |
| ca.ext_aquaregia_mg.kg   |      1128 | 634.26 | 1352.25 |  0.00 |  52.50 | 186.94 | 589.29 | 19922.26 |
| mg.ext_aquaregia_mg.kg   |      1128 | 800.40 | 1425.40 |  9.27 |  79.37 | 141.16 | 836.50 |  9500.41 |
| k.ext_aquaregia_mg.kg    |      1128 | 616.41 | 1020.57 |  7.96 |  77.21 | 163.31 | 795.00 |  8073.54 |
| mn.ext_aquaregia_mg.kg   |      1128 | 480.73 |  934.36 |  2.23 |  30.09 |  64.16 | 455.98 |  6468.45 |
| na.ext_aquaregia_mg.kg   |      1128 |  69.57 |  128.62 |  0.00 |   4.99 |  13.99 |  71.72 |  1213.29 |
| p.ext_aquaregia_mg.kg    |      1128 | 534.89 |  773.33 | 13.90 | 130.72 | 214.20 | 580.34 |  6679.17 |

MIR spectral visualization (100 random spectra):

``` r
set.seed(42)
caf.mir %>%
  sample_n(100) %>%
  select(all_of(c("id.layer_local_c")), starts_with("scan_mir.")) %>%
  tidyr::pivot_longer(-all_of(c("id.layer_local_c")),
                      names_to = "wavenumber", values_to = "absorbance") %>%
  dplyr::mutate(wavenumber = gsub("scan_mir.|_abs", "", wavenumber)) %>%
  dplyr::mutate(wavenumber = as.numeric(wavenumber)) %>%
  ggplot(aes(x = wavenumber, y = absorbance, group = id.layer_local_c)) +
  geom_line(alpha = 0.1) +
  scale_x_continuous(breaks = c(600, 1200, 1800, 2400, 3000, 3600, 4000),
                     transform = "reverse") +
  labs(x = bquote("Wavenumber"~(cm^-1)), y = "Absorbance") +
  theme_light()
```

![](README_files/figure-commonmark/mir_plot-1.png)

``` r
toc()
```

    4.088 sec elapsed

``` r
rm(list = ls())
gc()
```

              used  (Mb) gc trigger  (Mb) limit (Mb) max used  (Mb)
    Ncells 4316898 230.6    6673241 356.4         NA  6527648 348.7
    Vcells 7909129  60.4   29923218 228.3      32768 37404014 285.4

## References

<div id="refs" class="references csl-bib-body hanging-indent"
entry-spacing="0" line-spacing="2">

<div id="ref-summerauer2021central" class="csl-entry">

Summerauer, L., Baumann, P., Ramirez-Lopez, L., Barthel, M., Bauters,
M., Bukombe, B., et al.others. (2021). The central african soil spectral
library: A new soil infrared repository and a geographical prediction
analysis. *SOIL*, *7*(2), 693–715.
doi:[10.5194/soil-7-693-2021](https://doi.org/10.5194/soil-7-693-2021)

</div>

</div>
