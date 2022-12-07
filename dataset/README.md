Binding all datasets
================
Jose Lucas Safanelli (<jsafanelli@woodwellclimate.org>), Tomislav Hengl
(<tom.hengl@opengeohub.org>), Jonathan Sanderman
(<jsanderman@woodwellclimate.org>) -
07 December, 2022



-   [Description](#description)
-   [Binding and joining](#binding-and-joining)
-   [References](#references)

[<img src="../img/soilspec4gg-logo_fc.png" alt="SoilSpec4GG logo" width="250"/>](https://soilspectroscopy.org/)

[<img alt="Creative Commons License" style="border-width:0" src="https://i.creativecommons.org/l/by-sa/4.0/88x31.png" />](http://creativecommons.org/licenses/by-sa/4.0/)

This work is licensed under a [Creative Commons Attribution-ShareAlike
4.0 International
License](http://creativecommons.org/licenses/by-sa/4.0/).

## Description

Part of: <https://github.com/soilspectroscopy>  
Project: [Soil Spectroscopy for Global
Good](https://soilspectroscopy.org)  
Last update: 2022-12-07

All the external SSLs were prepared and harmonized to the OSSL naming
conventions as described in the `README` files present in each specific
folder. Site, soil, MIR, and VisNIR data were all exported to a local
working server as `qs` serial files (R package `qs`). The exported
naming convention follows the standard
`<local DATASET folder>/ossl_<data table>_<version>.<format>`:

-   `<local DATASET folder>/ossl_soilsite_v1.2.qs`: Imported/harmonized
    site data in `qs` format.  
-   `<local DATASET folder>/ossl_soilab_v1.2.qs`: Imported/harmonized
    soil reference data in `qs` format.  
-   `<local DATASET folder>/ossl_mir_v1.2.qs`: Imported/harmonized MIR
    data in `qs` format.  
-   `<local DATASET folder>/ossl_visnir_v1.2.qs`: Imported/harmonized
    ViSNIR data in `qs` format.

## Binding and joining

R packages

``` r
packages <- c("tidyverse", "tidymodels", "data.table", "fs", "qs", "tictoc")
new.packages <- packages[!(packages %in% installed.packages()[,"Package"])]
if(length(new.packages)) install.packages(new.packages)
invisible(lapply(packages, library, character.only = TRUE))
source("../R-code/functions/SSL_functions.R")
```

Directory/folder path

``` r
dir = "/mnt/soilspec4gg/ossl/dataset/"
tic()
```

Listing, reading and row binding `qs` files

``` r
qs.files <- dir_ls(dir, recurse = T, regexp = glob2rx("*v1.2.qs"))

qs.soilsite <- as.vector(grep("_soilsite_", qs.files, value = T))
qs.soilsite.ids <- tibble(file_sequence = as.character(1:length(qs.soilsite)), code = basename(dirname(qs.soilsite)))

qs.soillab <- as.vector(grep("_soillab_", qs.files, value = T))
qs.soillab.ids <- tibble(file_sequence = as.character(1:length(qs.soillab)), code = basename(dirname(qs.soillab)))

qs.visnir <- as.vector(grep("_visnir_", qs.files, value = T))
qs.visnir.ids <- tibble(file_sequence = as.character(1:length(qs.visnir)), code = basename(dirname(qs.visnir)))

qs.mir <- as.vector(grep("_mir_", qs.files, value = T))
qs.mir.ids <- tibble(file_sequence = as.character(1:length(qs.mir)), code = basename(dirname(qs.mir)))

## Reading soilsite files
ossl.soilsite <- map_dfr(.x = qs.soilsite,
                       .f = function(.x) {
                         qread(.x) %>%
                           mutate_all(as.character)},
                       .id = "file_sequence") %>%
  left_join(qs.soilsite.ids, by = "file_sequence") %>%
  relocate(code, .before = 1)

ossl.soilsite %>%
  glimpse()
```

    ## Rows: 158,555
    ## Columns: 35
    ## $ code                                       <chr> "AFSIS", "AFSIS", "AFSIS", …
    ## $ file_sequence                              <chr> "1", "1", "1", "1", "1", "1…
    ## $ id.layer_local_c                           <chr> "icr025136", "icr068579", "…
    ## $ longitude.point_wgs84_dd                   <chr> "34.24331284", "8.166768333…
    ## $ latitude.point_wgs84_dd                    <chr> "-6.8516202", "11.28065833"…
    ## $ layer.sequence_usda_uint16                 <chr> "2", "1", "2", "2", "1", "2…
    ## $ layer.upper.depth_usda_cm                  <chr> "20", "0", "20", "20", "0",…
    ## $ layer.lower.depth_usda_cm                  <chr> "50", "20", "50", "50", "20…
    ## $ observation.date.begin_iso.8601_yyyy.mm.dd <chr> "2011-01-01", "2011-01-01",…
    ## $ observation.date.end_iso.8601_yyyy.mm.dd   <chr> "2013-12-31", "2013-12-31",…
    ## $ surveyor.title_utf8_txt                    <chr> "Tor Vagen", "Jerome Tondoh…
    ## $ id.project_ascii_txt                       <chr> "Africa Soil Information Se…
    ## $ id.layer_uuid_txt                          <chr> "bdd9d5a45e1821c225d17a982c…
    ## $ id.location_olc_txt                        <chr> "6G5P46XV+98", "7F3C75J8+7P…
    ## $ layer.texture_usda_txt                     <chr> "", "", "", "", "", "", "",…
    ## $ pedon.taxa_usda_txt                        <chr> "", "", "", "", "", "", "",…
    ## $ horizon.designation_usda_txt               <chr> "", "", "", "", "", "", "",…
    ## $ longitude.county_wgs84_dd                  <chr> NA, NA, NA, NA, NA, NA, NA,…
    ## $ latitude.county_wgs84_dd                   <chr> NA, NA, NA, NA, NA, NA, NA,…
    ## $ location.point.error_any_m                 <chr> "30", "30", "30", "30", "30…
    ## $ location.country_iso.3166_txt              <chr> "", "", "", "", "", "", "",…
    ## $ observation.ogc.schema.title_ogc_txt       <chr> "Open Soil Spectroscopy Lib…
    ## $ observation.ogc.schema_idn_url             <chr> "https://soilspectroscopy.g…
    ## $ surveyor.contact_ietf_email                <chr> "afsis.info@africasoils.net…
    ## $ surveyor.address_utf8_txt                  <chr> "ICRAF, PO Box 30677, Nairo…
    ## $ dataset.title_utf8_txt                     <chr> "Africa Soil Information Se…
    ## $ dataset.owner_utf8_txt                     <chr> "ICRAF, CROPNUTS, RRES", "I…
    ## $ dataset.code_ascii_txt                     <chr> "AFSIS1.SSL", "AFSIS1.SSL",…
    ## $ dataset.address_idn_url                    <chr> "https://www.isric.org/expl…
    ## $ dataset.doi_idf_url                        <chr> "https://doi.org/10.1016/j.…
    ## $ dataset.license.title_ascii_txt            <chr> "ODC Open Database License"…
    ## $ dataset.license.address_idn_url            <chr> "https://opendatacommons.or…
    ## $ dataset.contact.name_utf8_txt              <chr> "Keith Shepherd", "Keith Sh…
    ## $ dataset.contact_ietf_email                 <chr> "afsis.info@africasoils.net…
    ## $ id.dataset.site_ascii_txt                  <chr> NA, NA, NA, NA, NA, NA, NA,…

``` r
## Reading soillab files
ossl.soillab <- map_dfr(.x = qs.soillab,
                       .f = qread,
                       .id = "file_sequence") %>%
  left_join(qs.soillab.ids, by = "file_sequence") %>%
  relocate(code, .before = 1)

ossl.soillab %>%
  glimpse()
```

    ## Rows: 151,187
    ## Columns: 81
    ## $ code                            <chr> "AFSIS", "AFSIS", "AFSIS", "AFSIS", "A…
    ## $ file_sequence                   <chr> "1", "1", "1", "1", "1", "1", "1", "1"…
    ## $ id.layer_local_c                <chr> "icr074433", "icr075957", "icr074336",…
    ## $ ec_usda.a364_ds.m               <dbl> 0.086, 0.139, 0.174, 0.040, 0.135, 0.1…
    ## $ al.ext_usda.a1056_mg.kg         <dbl> 346.00, 584.00, 502.00, 1378.21, 1180.…
    ## $ b.ext_mel3_mg.kg                <dbl> 0.230, 0.001, 0.760, 0.053, 0.001, 0.2…
    ## $ ca.ext_usda.a1059_mg.kg         <dbl> 1960.0, 5290.0, 8090.0, 219.4, 74.9, 1…
    ## $ cu.ext_usda.a1063_mg.kg         <dbl> 1.670, 4.250, 3.430, 1.933, 0.900, 0.0…
    ## $ fe.ext_usda.a1064_mg.kg         <dbl> 51.00, 92.50, 36.20, 87.73, 119.00, 17…
    ## $ k.ext_usda.a1065_mg.kg          <dbl> 178.000, 114.000, 387.000, 88.712, 29.…
    ## $ mg.ext_usda.a1066_mg.kg         <dbl> 415.00, 823.00, 905.00, 69.33, 34.80, …
    ## $ mn.ext_usda.a1067_mg.kg         <dbl> 76.400, 12.300, 69.200, 30.530, 5.730,…
    ## $ na.ext_usda.a1068_mg.kg         <dbl> 24.50, 87.70, 46.30, 18.35, 43.60, 53.…
    ## $ p.ext_usda.a652_mg.kg           <dbl> 4.500, 3.330, 5.620, 0.861, 1.530, 3.6…
    ## $ s.ext_mel3_mg.kg                <dbl> 6.830, 26.300, 12.300, 18.532, 39.200,…
    ## $ zn.ext_usda.a1073_mg.kg         <dbl> 1.180, 1.650, 1.170, 0.245, 0.670, 0.6…
    ## $ ph.h2o_usda.a268_index          <dbl> 8.150, 7.360, 8.400, 4.856, 4.320, 4.5…
    ## $ n.tot_usda.a623_w.pct           <dbl> 0.04387065, 0.06121826, 0.06013734, 0.…
    ## $ c.tot_usda.a622_w.pct           <dbl> 0.5704002, 0.9474234, 1.2782017, 1.894…
    ## $ oc_usda.c1059_w.pct             <dbl> 0.6151460, 0.9277148, 1.1795179, 1.876…
    ## $ clay.tot_usda.a334_w.pct        <dbl> 100.000, 100.000, 100.000, 99.270, 97.…
    ## $ silt.tot_usda.c62_w.pct         <dbl> NA, NA, NA, 0.730, 2.640, 3.260, 2.570…
    ## $ sand.tot_usda.c60_w.pct         <dbl> NA, NA, NA, NA, NA, NA, 0.120, 0.120, …
    ## $ ph.cacl2_usda.a481_index        <dbl> NA, NA, NA, NA, NA, NA, NA, NA, NA, NA…
    ## $ al.ext_aquaregia_g.kg           <dbl> NA, NA, NA, NA, NA, NA, NA, NA, NA, NA…
    ## $ fe.ext_aquaregia_g.kg           <dbl> NA, NA, NA, NA, NA, NA, NA, NA, NA, NA…
    ## $ ca.ext_aquaregia_mg.kg          <dbl> NA, NA, NA, NA, NA, NA, NA, NA, NA, NA…
    ## $ mg.ext_aquaregia_mg.kg          <dbl> NA, NA, NA, NA, NA, NA, NA, NA, NA, NA…
    ## $ k.ext_aquaregia_mg.kg           <dbl> NA, NA, NA, NA, NA, NA, NA, NA, NA, NA…
    ## $ mn.ext_aquaregia_mg.kg          <dbl> NA, NA, NA, NA, NA, NA, NA, NA, NA, NA…
    ## $ na.ext_aquaregia_mg.kg          <dbl> NA, NA, NA, NA, NA, NA, NA, NA, NA, NA…
    ## $ p.ext_aquaregia_mg.kg           <dbl> NA, NA, NA, NA, NA, NA, NA, NA, NA, NA…
    ## $ layer.upper.depth_usda_cm       <dbl> NA, NA, NA, NA, NA, NA, NA, NA, NA, NA…
    ## $ layer.lower.depth_usda_cm       <dbl> NA, NA, NA, NA, NA, NA, NA, NA, NA, NA…
    ## $ bd_usda.a4_g.cm3                <dbl> NA, NA, NA, NA, NA, NA, NA, NA, NA, NA…
    ## $ wr.10kPa_usda.a414_w.pct        <dbl> NA, NA, NA, NA, NA, NA, NA, NA, NA, NA…
    ## $ wr.1500kPa_usda.a417_w.pct      <dbl> NA, NA, NA, NA, NA, NA, NA, NA, NA, NA…
    ## $ p.ext_usda.a274_mg.kg           <dbl> NA, NA, NA, NA, NA, NA, NA, NA, NA, NA…
    ## $ p.ext_usda.a270_mg.kg           <dbl> NA, NA, NA, NA, NA, NA, NA, NA, NA, NA…
    ## $ cec_usda.a723_cmolc.kg          <dbl> NA, NA, NA, NA, NA, NA, NA, NA, NA, NA…
    ## $ ca.ext_usda.a722_cmolc.kg       <dbl> NA, NA, NA, NA, NA, NA, NA, NA, NA, NA…
    ## $ mg.ext_usda.a724_cmolc.kg       <dbl> NA, NA, NA, NA, NA, NA, NA, NA, NA, NA…
    ## $ k.ext_usda.a725_cmolc.kg        <dbl> NA, NA, NA, NA, NA, NA, NA, NA, NA, NA…
    ## $ na.ext_usda.a726_cmolc.kg       <dbl> NA, NA, NA, NA, NA, NA, NA, NA, NA, NA…
    ## $ caco3_usda.a54_w.pct            <dbl> NA, NA, NA, NA, NA, NA, NA, NA, NA, NA…
    ## $ acidity_usda.a795_cmolc.kg      <dbl> NA, NA, NA, NA, NA, NA, NA, NA, NA, NA…
    ## $ al.ext_usda.a69_cmolc.kg        <dbl> NA, NA, NA, NA, NA, NA, NA, NA, NA, NA…
    ## $ bd_usda.a21_g.cm3               <dbl> NA, NA, NA, NA, NA, NA, NA, NA, NA, NA…
    ## $ wr.10kPa_usda.a8_w.pct          <dbl> NA, NA, NA, NA, NA, NA, NA, NA, NA, NA…
    ## $ wr.33kPa_usda.a9_w.pct          <dbl> NA, NA, NA, NA, NA, NA, NA, NA, NA, NA…
    ## $ aggstb_usda.a1_w.pct            <dbl> NA, NA, NA, NA, NA, NA, NA, NA, NA, NA…
    ## $ al.dith_usda.a65_w.pct          <dbl> NA, NA, NA, NA, NA, NA, NA, NA, NA, NA…
    ## $ al.ox_usda.a59_w.pct            <dbl> NA, NA, NA, NA, NA, NA, NA, NA, NA, NA…
    ## $ awc.33.1500kPa_usda.c80_cm3.cm3 <dbl> NA, NA, NA, NA, NA, NA, NA, NA, NA, NA…
    ## $ bd_usda.c85_g.cm3               <dbl> NA, NA, NA, NA, NA, NA, NA, NA, NA, NA…
    ## $ cf_usda.c236_w.pct              <dbl> NA, NA, NA, NA, NA, NA, NA, NA, NA, NA…
    ## $ fe.dith_usda.a66_w.pct          <dbl> NA, NA, NA, NA, NA, NA, NA, NA, NA, NA…
    ## $ fe.ox_usda.a60_w.pct            <dbl> NA, NA, NA, NA, NA, NA, NA, NA, NA, NA…
    ## $ mn.ext_usda.a70_mg.kg           <dbl> NA, NA, NA, NA, NA, NA, NA, NA, NA, NA…
    ## $ oc_usda.c729_w.pct              <dbl> NA, NA, NA, NA, NA, NA, NA, NA, NA, NA…
    ## $ p.ext_usda.a1070_mg.kg          <dbl> NA, NA, NA, NA, NA, NA, NA, NA, NA, NA…
    ## $ ph.cacl2_usda.a477_index        <dbl> NA, NA, NA, NA, NA, NA, NA, NA, NA, NA…
    ## $ s.tot_usda.a624_w.pct           <dbl> NA, NA, NA, NA, NA, NA, NA, NA, NA, NA…
    ## $ sand.tot_usda.c405_w.pct        <dbl> NA, NA, NA, NA, NA, NA, NA, NA, NA, NA…
    ## $ silt.tot_usda.c407_w.pct        <dbl> NA, NA, NA, NA, NA, NA, NA, NA, NA, NA…
    ## $ wr.33kPa_usda.a415_w.pct        <dbl> NA, NA, NA, NA, NA, NA, NA, NA, NA, NA…
    ## $ efferv_usda.a479_class          <chr> NA, NA, NA, NA, NA, NA, NA, NA, NA, NA…
    ## $ cf_ISO.11464_w.pct              <dbl> NA, NA, NA, NA, NA, NA, NA, NA, NA, NA…
    ## $ clay.tot_ISO.11277_w.pct        <dbl> NA, NA, NA, NA, NA, NA, NA, NA, NA, NA…
    ## $ silt.tot_ISO.11277_w.pct        <dbl> NA, NA, NA, NA, NA, NA, NA, NA, NA, NA…
    ## $ sand.tot_ISO.11277_w.pct        <dbl> NA, NA, NA, NA, NA, NA, NA, NA, NA, NA…
    ## $ ph.h2o_ISO.10390_index          <dbl> NA, NA, NA, NA, NA, NA, NA, NA, NA, NA…
    ## $ ph.cacl2_ISO.10390_index        <dbl> NA, NA, NA, NA, NA, NA, NA, NA, NA, NA…
    ## $ oc_ISO.10694_w.pct              <dbl> NA, NA, NA, NA, NA, NA, NA, NA, NA, NA…
    ## $ caco3_ISO.10693_w.pct           <dbl> NA, NA, NA, NA, NA, NA, NA, NA, NA, NA…
    ## $ n.tot_ISO.11261_w.pct           <dbl> NA, NA, NA, NA, NA, NA, NA, NA, NA, NA…
    ## $ p.ext_ISO.11263_mg.kg           <dbl> NA, NA, NA, NA, NA, NA, NA, NA, NA, NA…
    ## $ cec_ISO.11260_cmolc.kg          <dbl> NA, NA, NA, NA, NA, NA, NA, NA, NA, NA…
    ## $ ec_ISO.11265_ds.m               <dbl> NA, NA, NA, NA, NA, NA, NA, NA, NA, NA…
    ## $ n.tot_ISO.13878_w.pct           <dbl> NA, NA, NA, NA, NA, NA, NA, NA, NA, NA…
    ## $ c.tot_ISO.10694_w.pct           <dbl> NA, NA, NA, NA, NA, NA, NA, NA, NA, NA…

``` r
## Reading visnir files
ossl.visnir <- map_dfr(.x = qs.visnir,
                       .f = qread,
                       .id = "file_sequence") %>%
  left_join(qs.visnir.ids, by = "file_sequence") %>%
  relocate(contains("_ref"), .after = last_col()) %>%
  relocate(code, .before = 1)

ossl.visnir %>%
  select(!contains("_ref"), scan_visnir.1000_ref) %>%
  glimpse()
```

    ## Rows: 65,063
    ## Columns: 16
    ## $ code                                       <chr> "ICRAF_ISRIC", "ICRAF_ISRIC…
    ## $ file_sequence                              <chr> "1", "1", "1", "1", "1", "1…
    ## $ id.layer_local_c                           <chr> "FS15R_FS4068", "FS15R_FS40…
    ## $ id.scan_local_c                            <chr> "FS15R_FS4068", "FS15R_FS40…
    ## $ scan.visnir.date.begin_iso.8601_yyyy.mm.dd <date> 2004-02-01, 2004-02-01, 20…
    ## $ scan.visnir.date.end_iso.8601_yyyy.mm.dd   <date> 2004-11-01, 2004-11-01, 20…
    ## $ scan.visnir.model.name_utf8_txt            <chr> "ASD FieldSpec Pro FR", "AS…
    ## $ scan.visnir.model.code_any_txt             <chr> "ASD_FieldSpec_FR", "ASD_Fi…
    ## $ scan.visnir.method.light.source_any_txt    <chr> "4.5 W halogen lamp", "4.5 …
    ## $ scan.visnir.method.preparation_any_txt     <chr> "", "", "", "", "", "", "",…
    ## $ scan.visnir.license.title_ascii_txt        <chr> "CC-BY", "CC-BY", "CC-BY", …
    ## $ scan.visnir.license.address_idn_url        <chr> "https://creativecommons.or…
    ## $ scan.visnir.doi_idf_url                    <chr> "https://doi.org/10.34725/D…
    ## $ scan.visnir.contact.name_utf8_txt          <chr> "Keith Shepherd", "Keith Sh…
    ## $ scan.visnir.contact.email_ietf_txt         <chr> "afsis.info@africasoils.net…
    ## $ scan_visnir.1000_ref                       <dbl> 0.4005380, 0.5228800, 0.534…

``` r
## Reading mir files
ossl.mir <- map_dfr(.x = qs.mir,
                       .f = qread,
                       .id = "file_sequence") %>%
  left_join(qs.mir.ids, by = "file_sequence") %>%
  relocate(contains("_abs"), .after = last_col()) %>%
  relocate(code, .before = 1)

ossl.mir %>%
  select(!contains("_abs"), scan_mir.1000_abs) %>%
  glimpse()
```

    ## Rows: 91,692
    ## Columns: 17
    ## $ code                                    <chr> "AFSIS", "AFSIS", "AFSIS", "AF…
    ## $ file_sequence                           <chr> "1", "1", "1", "1", "1", "1", …
    ## $ id.layer_local_c                        <chr> "icr072246", "icr072247", "icr…
    ## $ id.scan_local_c                         <chr> "icr072246", "icr072247", "icr…
    ## $ scan.mir.date.begin_iso.8601_yyyy.mm.dd <date> 2009-01-01, 2009-01-01, 2009-…
    ## $ scan.mir.date.end_iso.8601_yyyy.mm.dd   <date> 2013-12-31, 2013-12-31, 2013-…
    ## $ scan.mir.model.name_utf8_txt            <chr> "Bruker Tensor 27 with HTS-XT …
    ## $ scan.mir.model.code_any_txt             <chr> "Bruker_Tensor_27.HTS.XT", "Br…
    ## $ scan.mir.method.light.source_any_txt    <chr> "", "", "", "", "", "", "", ""…
    ## $ scan.mir.method.preparation_any_txt     <chr> "", "", "", "", "", "", "", ""…
    ## $ scan.mir.license.title_ascii_txt        <chr> "CC-BY", "CC-BY", "CC-BY", "CC…
    ## $ scan.mir.license.address_idn_url        <chr> "https://creativecommons.org/l…
    ## $ scan.mir.doi_idf_url                    <chr> "https://doi.org/10.34725/DVN/…
    ## $ scan.mir.contact.name_utf8_txt          <chr> "Vagen, Tor-Gunnar (World Agro…
    ## $ scan.mir.contact.email_ietf_txt         <chr> "afsis.info@africasoils.net", …
    ## $ dataset.code_ascii_txt                  <chr> NA, NA, NA, NA, NA, NA, NA, NA…
    ## $ scan_mir.1000_abs                       <dbl> 1.189548, 1.286010, 1.298255, …

Joining data files

``` r
# First full joining mir and visnir as some observations might not have both spectra types
ossl.spectra <- full_join(ossl.mir, ossl.visnir, by = "id.layer_local_c")

ossl.spectra %>%
  select(ends_with(".x")) %>%
  names()
```

    ## [1] "code.x"            "file_sequence.x"   "id.scan_local_c.x"

``` r
# Coalescing repeated columns, especially because we have LUCAS.WOODWELL MIR
ossl.spectra <- ossl.spectra %>%
  mutate(id.scan_local_c = coalesce(id.scan_local_c.x, id.scan_local_c.y, NA),
         .after = id.scan_local_c.x) %>%
  mutate(code = coalesce(code.x, code.y, NA),
         file_sequence = coalesce(file_sequence.x, file_sequence.y, NA),
         .after = code.x) %>%
  select(-id.scan_local_c.x, -id.scan_local_c.y,
         -code.x, -code.y,
         -file_sequence.x, -file_sequence.y)

ossl.spectra %>%
  select(ends_with(".x")) %>%
  names()
```

    ## character(0)

``` r
# View(ossl.spectra %>% select(!contains("_ref|_abs")))

# Left joining site to soil info, as some site does not have lab data
ossl.info <- left_join(ossl.soillab, ossl.soilsite, by = "id.layer_local_c")

ossl.info %>%
  select(ends_with(".x")) %>%
  names()
```

    ## [1] "code.x"                      "file_sequence.x"            
    ## [3] "layer.upper.depth_usda_cm.x" "layer.lower.depth_usda_cm.x"

``` r
# Coalescing repeated columns, especially because some depth info was available from soillab data, not site
ossl.info <- ossl.info %>%
  mutate_at(vars(contains(c("layer.upper.depth_usda_cm", "layer.lower.depth_usda_cm"))), as.numeric) %>%
  mutate(layer.upper.depth_usda_cm = coalesce(layer.upper.depth_usda_cm.x, layer.upper.depth_usda_cm.y, NA),
         layer.lower.depth_usda_cm = coalesce(layer.lower.depth_usda_cm.x, layer.lower.depth_usda_cm.y, NA),
         .after = layer.lower.depth_usda_cm.x) %>%
  mutate(code = coalesce(code.x, code.y, NA),
         file_sequence = coalesce(file_sequence.x, file_sequence.y, NA),
         .after = code.x) %>%
  select(-layer.upper.depth_usda_cm.x, -layer.upper.depth_usda_cm.y,
         -layer.lower.depth_usda_cm.x, -layer.lower.depth_usda_cm.y,
         -code.x, -code.y,
         -file_sequence.x, -file_sequence.y)

ossl.info %>%
  select(ends_with(".x")) %>%
  names()
```

    ## character(0)

``` r
# Producing level 0 by left joining site and soil data to spectra data
ossl.level0 <- ossl.spectra %>%
  left_join(ossl.info, by = "id.layer_local_c")

ossl.level0 %>%
  select(ends_with(".x")) %>%
  names()
```

    ## [1] "code.x"                   "file_sequence.x"         
    ## [3] "dataset.code_ascii_txt.x"

``` r
# Coalescing repeated columns, especially because we have LUCAS.WOODWELL code
ossl.level0 <- ossl.level0 %>%
  mutate(dataset.code_ascii_txt = coalesce(dataset.code_ascii_txt.x, dataset.code_ascii_txt.y, NA),
         .after = dataset.code_ascii_txt.x) %>%
  mutate(code = coalesce(code.x, code.y, NA),
         file_sequence = coalesce(file_sequence.x, file_sequence.y, NA),
         .after = code.x) %>%
  select(-dataset.code_ascii_txt.x, -dataset.code_ascii_txt.y,
         -code.x, -code.y,
         -file_sequence.x, -file_sequence.y)

ossl.level0 %>%
  select(ends_with(".x")) %>%
  names()
```

    ## character(0)

``` r
# For some reason, some observations have soil and spectral measurements, but not site data
# We will automatically fill them with general metadata. ID, spatial and temporal info is ommitted
ossl.level0 %>%
  count(dataset.code_ascii_txt)
```

    ##     dataset.code_ascii_txt     n
    ##  1:             AFSIS1.SSL  1838
    ##  2:             AFSIS2.SSL   151
    ##  3:                CAF.SSL  1629
    ##  4:            GARRETT.SSL   184
    ##  5:            ICRAF.ISRIC  4073
    ##  6:               KSSL.SSL 86908
    ##  7:              LUCAS.SSL 40227
    ##  8:     LUCAS.WOODWELL.SSL   589
    ##  9:          SCHIEDUNG.SSL   259
    ## 10:                   <NA>  6234

``` r
soilsite.columns <- ossl.soilsite %>%
  select(starts_with(c("dataset", "observation", "surveyor")),
         id.dataset.site_ascii_txt, id.project_ascii_txt) %>%
  names()

# # Checking
# ossl.level0 %>%
#   select(!contains(c("_ref", "_abs"))) %>%
#   select(code, contains("id"), any_of(soilsite.columns)) %>%
#   filter(is.na(dataset.code_ascii_txt)) %>%
#   View()

# check.ids <- ossl.level0 %>%
#   filter(is.na(dataset.code_ascii_txt)) %>%
#   pull(id.scan_local_c)

ossl.level0.export <- ossl.level0 %>%
  group_by(code) %>%
  fill(all_of(soilsite.columns)) %>%
  ungroup()

# Removing duplicates
# ossl.level0.export %>%
#   group_by(dataset.code_ascii_txt, id.layer_local_c) %>%
#   summarise(repeats = n()) %>%
#   group_by(repeats) %>%
#   summarise(count = n())

dupli.ids <- ossl.level0.export %>%
  group_by(dataset.code_ascii_txt, id.layer_local_c) %>%
  summarise(repeats = n()) %>%
  filter(repeats > 1) %>%
  pull(id.layer_local_c)

# Removing duplicates and rearranging columns
ossl.level0.export <- ossl.level0.export %>%
  filter(!(id.layer_local_c %in% dupli.ids)) %>%
  select(any_of(names(ossl.soilsite)), any_of(sort(names(ossl.soillab))), any_of(names(ossl.spectra))) %>%
  select(dataset.code_ascii_txt, contains("id."), everything())

# # Checking
# ossl.level0.export %>%
#   select(!contains(c("_ref", "_abs"))) %>%
#   select(code, contains("id"), any_of(soilsite.columns)) %>%
#   filter(id.scan_local_c %in% check.ids) %>%
#   View()

# # Glimpse of column types
# ossl.level0.export %>%
#   select(!contains(c("_ref", "_abs"))) %>%
#   glimpse()

# Mutating to proper column types
ossl.level0.export <- ossl.level0.export %>%
  mutate(longitude.point_wgs84_dd = as.numeric(longitude.point_wgs84_dd),
         latitude.point_wgs84_dd = as.numeric(latitude.point_wgs84_dd),
         layer.sequence_usda_uint16 = as.numeric(layer.sequence_usda_uint16),
         layer.upper.depth_usda_cm = as.numeric(layer.upper.depth_usda_cm),
         layer.lower.depth_usda_cm = as.numeric(layer.lower.depth_usda_cm),
         observation.date.begin_iso.8601_yyyy.mm.dd = lubridate::ymd(observation.date.begin_iso.8601_yyyy.mm.dd),
         observation.date.end_iso.8601_yyyy.mm.dd = lubridate::ymd(observation.date.end_iso.8601_yyyy.mm.dd),
         layer.texture_usda_txt = ifelse("", NA_character_, layer.texture_usda_txt),
         pedon.taxa_usda_txt = ifelse("", NA_character_, pedon.taxa_usda_txt),
         horizon.designation_usda_txt = ifelse("", NA_character_, horizon.designation_usda_txt),
         longitude.county_wgs84_dd = as.numeric(longitude.county_wgs84_dd),
         latitude.county_wgs84_dd = as.numeric(latitude.county_wgs84_dd),
         location.point.error_any_m = as.numeric(location.point.error_any_m),
         location.country_iso.3166_txt = ifelse("", NA_character_, location.country_iso.3166_txt),
         scan.mir.method.light.source_any_txt = ifelse("", NA_character_, scan.mir.method.light.source_any_txt),
         scan.mir.method.preparation_any_txt = ifelse("", NA_character_, scan.mir.method.preparation_any_txt),
         scan.visnir.method.light.source_any_txt = ifelse("", NA_character_, scan.visnir.method.light.source_any_txt),
         scan.visnir.method.preparation_any_txt = ifelse("", NA_character_, scan.visnir.method.preparation_any_txt))

# Checking for complete spatial locations
ossl.level0.export %>%
  mutate(complete_location = is.na(longitude.point_wgs84_dd)&!is.na(latitude.point_wgs84_dd)) %>%
  count(complete_location)
```

    ## # A tibble: 1 × 2
    ##   complete_location      n
    ##   <lgl>              <int>
    ## 1 FALSE             141762

``` r
# Checking for missing spatial locations
ossl.level0.export %>%
  mutate(missing_location = is.na(longitude.point_wgs84_dd)) %>%
  count(missing_location)
```

    ## # A tibble: 2 × 2
    ##   missing_location     n
    ##   <lgl>            <int>
    ## 1 FALSE            87623
    ## 2 TRUE             54139

``` r
# Running unique id with dataset and layer id combination, and olc location code 
ossl.level0.export <- ossl.level0.export %>%
  mutate(location.point.error_any_m = ifelse(is.na(longitude.point_wgs84_dd), NA, location.point.error_any_m)) %>%
  mutate(id.layer_uuid_txt = openssl::md5(paste0(dataset.code_ascii_txt, id.layer_local_c)),
         id.location_olc_txt = olctools::encode_olc(latitude.point_wgs84_dd, longitude.point_wgs84_dd, 10)) %>%
  select(-code, -file_sequence) %>%
  relocate(id.layer_uuid_txt, .after = id.layer_local_c)

# # Checking
# ossl.level0.export %>%
#   select(!contains(c("_ref", "_abs"))) %>%
#   View()

# Final spectral counts
ossl.level0.export %>%
  mutate(available_mir = !is.na(scan_mir.1000_abs),
         available_visnir = !is.na(scan_visnir.1000_ref)) %>%
  count(dataset.code_ascii_txt, available_mir, available_visnir) %>%
  group_by(dataset.code_ascii_txt) %>%
  mutate(perc_dataset = round(n/sum(n)*100, 2))
```

    ## # A tibble: 12 × 5
    ## # Groups:   dataset.code_ascii_txt [9]
    ##    dataset.code_ascii_txt available_mir available_visnir     n perc_dataset
    ##    <chr>                  <lgl>         <lgl>            <int>        <dbl>
    ##  1 AFSIS1.SSL             TRUE          FALSE             1904       100   
    ##  2 AFSIS2.SSL             TRUE          FALSE              151       100   
    ##  3 CAF.SSL                TRUE          FALSE             1561       100   
    ##  4 GARRETT.SSL            TRUE          FALSE              184       100   
    ##  5 ICRAF.ISRIC            FALSE         TRUE               285         6.42
    ##  6 ICRAF.ISRIC            TRUE          TRUE              4153        93.6 
    ##  7 KSSL.SSL               FALSE         TRUE              9784        10.6 
    ##  8 KSSL.SSL               TRUE          FALSE            72702        78.6 
    ##  9 KSSL.SSL               TRUE          TRUE             10001        10.8 
    ## 10 LUCAS.SSL              FALSE         TRUE             40177       100   
    ## 11 LUCAS.WOODWELL.SSL     TRUE          TRUE               589       100   
    ## 12 SCHIEDUNG.SSL          TRUE          FALSE              271       100

``` r
# Final spatial counts
ossl.level0.export %>%
  mutate(missing_location = is.na(longitude.point_wgs84_dd)) %>%
  count(dataset.code_ascii_txt, missing_location) %>%
  group_by(dataset.code_ascii_txt) %>%
  mutate(perc_dataset = round(n/sum(n)*100, 2))
```

    ## # A tibble: 14 × 4
    ## # Groups:   dataset.code_ascii_txt [9]
    ##    dataset.code_ascii_txt missing_location     n perc_dataset
    ##    <chr>                  <lgl>            <int>        <dbl>
    ##  1 AFSIS1.SSL             FALSE             1838        96.5 
    ##  2 AFSIS1.SSL             TRUE                66         3.47
    ##  3 AFSIS2.SSL             TRUE               151       100   
    ##  4 CAF.SSL                FALSE             1561       100   
    ##  5 GARRETT.SSL            FALSE              184       100   
    ##  6 ICRAF.ISRIC            FALSE             4013        90.4 
    ##  7 ICRAF.ISRIC            TRUE               425         9.58
    ##  8 KSSL.SSL               FALSE            39004        42.2 
    ##  9 KSSL.SSL               TRUE             53483        57.8 
    ## 10 LUCAS.SSL              FALSE            40175       100   
    ## 11 LUCAS.SSL              TRUE                 2         0   
    ## 12 LUCAS.WOODWELL.SSL     FALSE              589       100   
    ## 13 SCHIEDUNG.SSL          FALSE              259        95.6 
    ## 14 SCHIEDUNG.SSL          TRUE                12         4.43

Saving level 0 (L0) files:  
- `ossl_all_L0_v1.2.qs`: Final full OSSL level 0 data in `qs` format.  
- `ossl_soilsite_L0_v1.2.qs`: Final OSSL site data in `qs` format.  
- `ossl_soilab_L0_v1.2.qs`: Final OSSL soil reference data in `qs`
format.  
- `ossl_mir_L0_v1.2.qs`: Final OSSL MIR data in `qs` format.  
- `ossl_visnir_L0_v1.2.qs`: Final OSSL ViSNIR data in `qs` format.

The columns `id.dataset.site_ascii_txt` and `id.layer_uuid_txt` are used
as id/reference columns for joining and avoiding repeated information in
the separate files.

``` r
# Exporting full ossl L0
qs::qsave(ossl.level0.export, "/mnt/soilspec4gg/ossl/ossl_import/ossl_all_L0_v1.2.qs", preset = "high")

# Exporting soilsite L0
avoid.soilsite.columns <- c("code", "file_sequence")
selected.soilsite.columns <- names(ossl.soilsite)[!(names(ossl.soilsite) %in% avoid.soilsite.columns)]

final.soilsite <- ossl.level0.export %>%
  select(all_of(selected.soilsite.columns)) %>%
  relocate(dataset.code_ascii_txt, id.layer_uuid_txt, .before = 1)

qs::qsave(final.soilsite, "/mnt/soilspec4gg/ossl/ossl_import/ossl_soilsite_L0_v1.2.qs", preset = "high")

# Exporting soillab L0
avoid.soillab.columns <- c("code", "file_sequence", "id.layer_local_c")
selected.soillab.columns <- names(ossl.soillab)[!(names(ossl.soillab) %in% avoid.soillab.columns)]

final.soillab <- ossl.level0.export %>%
  select(dataset.code_ascii_txt, id.layer_uuid_txt, all_of(selected.soillab.columns))

qs::qsave(final.soillab, "/mnt/soilspec4gg/ossl/ossl_import/ossl_soillab_L0_v1.2.qs", preset = "high")

# Exporting mir L0
avoid.mir.columns <- c("code", "file_sequence", "id.layer_local_c")
selected.mir.columns <- names(ossl.mir)[!(names(ossl.mir) %in% avoid.mir.columns)]

final.mir <- ossl.level0.export %>%
  select(dataset.code_ascii_txt, id.layer_uuid_txt, all_of(selected.mir.columns))

qs::qsave(final.mir, "/mnt/soilspec4gg/ossl/ossl_import/ossl_mir_L0_v1.2.qs", preset = "high")

# Exporting visnir L0
avoid.visnir.columns <- c("code", "file_sequence", "id.layer_local_c")
selected.visnir.columns <- names(ossl.visnir)[!(names(ossl.visnir) %in% avoid.visnir.columns)]

final.visnir <- ossl.level0.export %>%
  select(dataset.code_ascii_txt, id.layer_uuid_txt, all_of(selected.visnir.columns))

qs::qsave(final.visnir, "/mnt/soilspec4gg/ossl/ossl_import/ossl_visnir_L0_v1.2.qs", preset = "high")
```

World map visualizations

``` r
# Still todo
# Export as gpkg
# Make world map
# Save separate files
# Save level 0
# Overlay with covariates
# Export golden dataset
```

Producing level 1 (L1) as a regression matrix for fitting models

``` r
# Still todo
# Export as gpkg
# Make world map
# Save separate files
# Save level 0
# Overlay with covariates
# Export golden dataset
```

Overlay with spatial covariates

``` r
# Still todo
# Export as gpkg
# Make world map
# Save separate files
# Save level 0
# Overlay with covariates
# Export golden dataset
```

Producing a golden dataset for enabling a systematic analysis that
shares the same base data (Spatial, VisNIR and MIR)

``` r
# Still todo
# Export as gpkg
# Make world map
# Save separate files
# Save level 0
# Overlay with covariates
# Export golden dataset
```

``` r
toc()
```

    ## 119.144 sec elapsed

``` r
rm(list = ls())
gc()
```

    ##           used  (Mb) gc trigger    (Mb)   max used    (Mb)
    ## Ncells 2527913 135.1    5036735   269.0    5036735   269.0
    ## Vcells 4867317  37.2 1482191309 11308.3 1510274279 11522.5

## References
