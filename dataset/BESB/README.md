# BESB dataset preparation for the OSSL
Ran Zhi, Jose L. Safanelli, Jonathan Sanderman
— 17 February, 2026.

- [The BSSL original data](#the-bssl-original-data)
- [Data standardization to the OSSL
  format](#data-standardization-to-the-ossl-format)

Code repository for preparing and importing the Brazilian Soil Spectral
Library (BSSL) dataset into the Open Soil Spectral Library.

Project: [Soil Spectroscopy for Global
Good](https://soilspectroscopy.org)  
Development: <https://github.com/soilspectroscopy>  
Last update: 2026-02-17  
Additional documentation:

## The BSSL original data

Site data, Soil lab data, Mid-Infrared Spectra (MIR), and Visible,
Near-Infrared and Shortwave-Infrared (Vis-NIR-SWIR) from the Brazilian
Soil Spectral Library (BSSL). Further information of the dataset can be
found in detail at Demattê et al. ([2019](#ref-dematte_brazilian_2019))
and Demattê et al. ([2022](#ref-dematte_brazilian_2022)).

Original files:  
- `BSSL_DB_V002.xlsx`: xlsx file with site information, soil
information, and spectral data.

Directory/folder path with original files (not uploaded to GitHub).

``` r
# dir = "./"
dir = "~/projects/mnt-ossl/import/dataset/BESB"
tic()
```

## Data standardization to the OSSL format

### Site information

``` r
besb.metadata <- read_excel(path(dir, "BSSL_DB_V002.xlsx"),
                                 sheet = "BSSL_Soil_Attributes_Dataset")
```

    Warning: Expecting numeric in G13893 / R13893C7: got '-18.556944.'

``` r
besb.sitedata <- besb.metadata %>%
  select(ID_Unique, Owner_code, Vis_NIR_SWIR_availability, MIR_availability, Depth_cm,
         Lat, Long, Region, Vegetation, Bioma, Geology) %>%
  rename(id.layer_local_c = ID_Unique,
         longitude.point_wgs84_dd = Long,
         latitude.point_wgs84_dd = Lat) %>%
  mutate(id.layer_local_c = as.character(id.layer_local_c)) %>%
  separate(Depth_cm, into = c("layer.upper.depth_usda_cm", "layer.lower.depth_usda_cm"), sep = "-") %>%
  mutate(across(starts_with("layer."), as.numeric)) %>%
  mutate(layer.sequence_usda_uint16 = ifelse(layer.upper.depth_usda_cm == 0, 1, 2)) %>%
  mutate(id.project_ascii_txt = "Brazilian Soil Spectral Library",
         dataset.code_ascii_txt = "Brazilian.SSL",
         observation.ogc.schema.title_ogc_txt = "Open Soil Spectroscopy Library",
         observation.ogc.schema_idn_url = "https://soilspectroscopy.github.io",
         surveyor.title_utf8_txt = "Luiz de Queiroz College of Agriculture, University of São Paulo, Piracicaba, São Paulo, Brazil",
         surveyor.contact_ietf_email = "jamdemat@usp.br",
         surveyor.address_utf8_txt = "Department of Soil Science, Luiz de Queiroz College of Agriculture (ESALQ), University of São Paulo (USP), Ave. Pádua Dias 11, Cx. Postal 9, 13418-900, Piracicaba, São Paulo, Brazil",
         dataset.title_utf8_txt = "Brazilian Soil Spectral Library",
         dataset.owner_utf8_txt = "Luiz de Queiroz College of Agriculture, University of São Paulo",
         
         dataset.address_idn_url = "https://bibliotecaespectral.wixsite.com/english",
         dataset.doi_idf_url = "https://doi.org/10.5281/zenodo.8361419",
         dataset.license.title_ascii_txt = "CC-BY",
         dataset.license.address_idn_url = "https://creativecommons.org/licenses/by/4.0/legalcode",
         dataset.contact.name_utf8_txt = "José A.M. Demattê",
         dataset.contact_ietf_email = "jamdemat@usp.br") %>%
  mutate(id.layer_uuid_txt = openssl::md5(paste0(dataset.code_ascii_txt, id.layer_local_c)),
         id.location_olc_txt = olctools::encode_olc(latitude.point_wgs84_dd, longitude.point_wgs84_dd, 10),
         .after = id.project_ascii_txt) %>%
  mutate_at(vars(starts_with("id.")), as.character)

# Saving version to dataset root dir
site.qs = path(dir, "ossl_soilsite_v2.0.qs")
qs::qsave(besb.sitedata, site.qs, preset = "high")
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

soillab.names <- besb.metadata %>%
  select(ID_Unique, Sand_gkg, Clay_gkg, SOM_gkg, pH_H2O, 
         Ca_mmolkg, Mg_mmolkg, Na_mmolkg, CEC_Ph7_mmolkg) %>%
  names(.) %>%
  tibble(original_name = .) %>%
  dplyr::mutate(table = 'BSSL_DB_V002.xlsx', .before = 1) %>%
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
                                         sheet = "BESB") %>%
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

| table             | original_name  | original_unit | ossl_abbrev | ossl_method | ossl_unit | ossl_convert                                             | ossl_name                 |
|:------------------|:---------------|:--------------|:------------|:------------|:----------|:---------------------------------------------------------|:--------------------------|
| BSSL_DB_V002.xlsx | ID_Unique      | NA            | NA          | NA          | NA        | NA                                                       | NA                        |
| BSSL_DB_V002.xlsx | Sand_gkg       | g/kg          | sand.tot    | usda.c405   | w.pct     | ifelse(as.numeric(x) \< 0, NA, as.numeric(x) / 10)       | sand.tot_usda.c405_w.pct  |
| BSSL_DB_V002.xlsx | Clay_gkg       | g/kg          | clay_tot    | usda.a334   | w.pct     | ifelse(as.numeric(x) \< 0, NA, as.numeric(x) / 10)       | clay.tot_usda.a334_w.pct  |
| BSSL_DB_V002.xlsx | SOC_gkg        | g/kg          | oc          | iso.10694   | w.pct     | ifelse(as.numeric(x) \< 0, NA, as.numeric(x)\*1.33 / 10) | oc_iso.10694_w.pct        |
| BSSL_DB_V002.xlsx | pH_H2O         | NA            | ph.h2o      | usda.a268   | index     | NA                                                       | ph.h2o_usda.a268_index    |
| BSSL_DB_V002.xlsx | Ca_mmolkg      | mmol/kg       | ca.ext      | usda.a722   | cmolc.kg  | ifelse(as.numeric(x) \< 0, NA, as.numeric(x) / 10)       | ca.ext_usda.a722_cmolc.kg |
| BSSL_DB_V002.xlsx | Mg_mmolkg      | mmol/kg       | mg.ext      | usda.a724   | cmolc.kg  | ifelse(as.numeric(x) \< 0, NA, as.numeric(x) / 10)       | mg.ext_usda.a724_cmolc.kg |
| BSSL_DB_V002.xlsx | Na_mmolkg      | mmol/kg       | na.ext      | usda.a726   | cmolc.kg  | ifelse(as.numeric(x) \< 0, NA, as.numeric(x) / 10)       | na.ext_usda.a726_cmolc.kg |
| BSSL_DB_V002.xlsx | CEC_Ph7_mmolkg | mmol/kg       | cec         | usda.a723   | cmolc.kg  | ifelse(as.numeric(x) \< 0, NA, as.numeric(x) / 10)       | cec_usda.a723_cmolc.kg    |

Standardizing soil data to the OSSL format:

``` r
besb.reference <- besb.metadata

# Harmonization of names and units
analytes.old.names <- transvalues %>%
  filter(table == "BSSL_DB_V002.xlsx") %>%
  pull(original_name)

analytes.new.names <- transvalues %>%
  filter(table == "BSSL_DB_V002.xlsx") %>%
  pull(ossl_name)

# Selecting and renaming
if("SOM_gkg" %in% names(besb.reference)) {
  besb.reference <- besb.reference %>% rename(SOC_gkg = SOM_gkg)
}

analytes.old.names.clean <- analytes.old.names[analytes.old.names != "ID_Unique"]
analytes.new.names.clean <- analytes.new.names[analytes.old.names != "ID_Unique"]

besb.soildata <- besb.reference %>%
  rename(id.layer_local_c = ID_Unique) %>%
  select(id.layer_local_c, all_of(analytes.old.names.clean)) %>%
  rename_with(~analytes.new.names.clean, all_of(analytes.old.names.clean)) %>%
  mutate(id.layer_local_c = as.character(id.layer_local_c)) %>%
  as.data.frame()

# Getting the formulas
functions.list <- transvalues %>%
  filter(table == "BSSL_DB_V002.xlsx") %>%
  mutate(ossl_name = factor(ossl_name, levels = names(besb.soildata))) %>%
  arrange(ossl_name) %>%
  pull(ossl_convert) %>%
  c("x", .)

# Applying transformation rules
besb.soildata.trans <- transform_values(df = besb.soildata,
                                       out.name = names(besb.soildata),
                                       in.name = names(besb.soildata),
                                       fun.lst = functions.list)

# Final soillab data
besb.soildata <- besb.soildata.trans %>%
  mutate_at(vars(starts_with("id.")), as.character)

# Checking total number of observations
besb.soildata %>%
  distinct(id.layer_local_c) %>%
  summarise(count = n())
```

      count
    1 16084

``` r
# Saving version to dataset root dir
soillab.qs = path(dir, "ossl_soillab_v2.0.qs")
qs::qsave(besb.soildata, soillab.qs, preset = "high")
```

<div id="refs" class="references csl-bib-body hanging-indent"
entry-spacing="0" line-spacing="2">

<div id="ref-dematte_brazilian_2019" class="csl-entry">

Demattê, J. A. M., Dotto, A. C., Paiva, A. F. S., Sato, M. V., Dalmolin,
R. S. D., De Araújo, M. D. S. B., … Do Couto, H. T. Z. (2019). The
Brazilian Soil Spectral Library (BSSL): A general view, application and
challenges. *Geoderma*, *354*, 113793.
doi:[10.1016/j.geoderma.2019.05.043](https://doi.org/10.1016/j.geoderma.2019.05.043)

</div>

<div id="ref-dematte_brazilian_2022" class="csl-entry">

Demattê, J. A. M., Paiva, A. F. D. S., Poppiel, R. R., Rosin, N. A.,
Ruiz, L. F. C., Mello, F. A. D. O., … Silvero, N. E. Q. (2022). The
Brazilian Soil Spectral Service (BraSpecS): A User-Friendly System for
Global Soil Spectra Communication. *Remote Sensing*, *14*(3), 740.
doi:[10.3390/rs14030740](https://doi.org/10.3390/rs14030740)

</div>

</div>
