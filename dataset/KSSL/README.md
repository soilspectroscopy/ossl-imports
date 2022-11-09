Dataset import: Kellogg Soil Survey Laboratory (KSSL)
================
Tomislav Hengl (<tom.hengl@opengeohub.org>), Jonathan Sanderman
(<jsanderman@woodwellclimate.org>), Develyn Bloom
(<develyn.bloom@ufl.edu>), and Jose Lucas Safanelli
(<jsafanelli@woodwellclimate.org>) -
09 November, 2022



-   [Kellogg Soil Survey Laboratory
    inputs](#kellogg-soil-survey-laboratory-inputs)
-   [Data import](#data-import)
    -   [Soil site information](#soil-site-information)
    -   [Soil lab information](#soil-lab-information)
    -   [Mid-infrared spectroscopy
        data](#mid-infrared-spectroscopy-data)
    -   [Quality control](#quality-control)
    -   [Rendering report](#rendering-report)
-   [References](#references)

[<img src="../../img/soilspec4gg-logo_fc.png" alt="SoilSpec4GG logo" width="250"/>](https://soilspectroscopy.org/)

[<img alt="Creative Commons License" style="border-width:0" src="https://i.creativecommons.org/l/by-sa/4.0/88x31.png" />](http://creativecommons.org/licenses/by-sa/4.0/)

This work is licensed under a [Creative Commons Attribution-ShareAlike
4.0 International
License](http://creativecommons.org/licenses/by-sa/4.0/).

## Kellogg Soil Survey Laboratory inputs

Part of: <https://github.com/soilspectroscopy>  
Project: [Soil Spectroscopy for Global
Good](https://soilspectroscopy.org)  
Last update: 2022-11-09  
Dataset:
[KSSL.SSL](https://soilspectroscopy.github.io/ossl-manual/soil-spectroscopy-tools-and-users.html#kssl.ssl)

The USDA-NRCS Kellogg Soil Survey Laboratory has a large and growing
mid-infrared (MIR) spectral library. Calibration models are being
developed to predict soil properties from MIR spectra. Dataset
properties are explained in detail in [Wijewardane, Ge, Wills, &
Libohova](#ref-wijewardane2018predicting)
([2018](#ref-wijewardane2018predicting)) and [Sanderman, Savage, &
Dangal](#ref-sanderman2020mid) ([2020](#ref-sanderman2020mid)).

<!-- Input datasets: -->
<!-- - `MIR_Spectra_Library_spectra_202011_202107.csv`: MIR soil spectral reflectances (>1700 channels); -->
<!-- - `vnir_09MAR2021.rds`: VNIR soil spectral reflectances (2151 channels) imported;   -->
<!-- - `All_Spectra_Access_Portable_7-7-21.mdb`: original DB as Microsoft Access MDB file;   -->

For the DB structure and use refer to “Introduction to the KSSL
Laboratory Information Management System” contacts: Rich Ferguson &
Scarlett Murphy (NRCS USDA).

The directory/folder path:

``` r
dir = "/mnt/soilspec4gg/ossl/dataset/KSSL/snapshot_Jul2022"
```

## Data import

### Soil site information

### Soil lab information

Run once! Original naming of soil properties, descriptions, data types,
and units. Run once and upload to Google Sheet for formatting and
integrating with the OSSL. Requires Google authentication.

``` r
analyte <- read_csv(paste0(dir, "/All_Spectra_Access_Portable_20220712/analyte.csv"))
calc <- read_csv(paste0(dir, "/All_Spectra_Access_Portable_20220712/calc.csv"))

soillab.names <- analyte %>%
  select(analyte.id, analyte.name, analyte.abbrev, uom.abbrev, analyte.desc) %>%
  mutate(source = "kssl_analyte", .before = 1) %>%
  rename(id = analyte.id, original_name = analyte.name, abbrev = analyte.abbrev,
         unit = uom.abbrev, original_description = analyte.desc) %>%
  bind_rows({calc %>%
      select(calc.id, calc.name, calc.abbrev, uom.abbrev, calc.desc) %>%
      mutate(source = "kssl_calc", .before = 1) %>%
      rename(id = calc.id, original_name = calc.name, abbrev = calc.abbrev,
             unit = uom.abbrev, original_description = calc.desc)}) %>%
  arrange(original_name) %>%
  dplyr::mutate(import = '', ossl_name = '', .after = original_name)

readr::write_csv(soillab.names, paste0(getwd(), "/kssl_soillab_names.csv"))

# Uploading to google sheet

# FACT CIN folder. Get ID for soildata importing table
googledrive::drive_ls(as_id("0AHDIWmLAj40_Uk9PVA"))

OSSL.soildata.importing <- "19LeILz9AEnKVK7GK0ZbK3CCr2RfeP-gSWn5VpY8ETVM"

# Checking metadata
googlesheets4::as_sheets_id(OSSL.soildata.importing)

# Checking readme
googlesheets4::read_sheet(OSSL.soildata.importing, sheet = 'readme')

# Preparing soillab.names
upload <- dplyr::as_tibble(soillab.names)

# Uploading
googlesheets4::write_sheet(upload, ss = OSSL.soildata.importing, sheet = "KSSL")

# Checking metadata
googlesheets4::as_sheets_id(OSSL.soildata.importing)
```

### Mid-infrared spectroscopy data

### Quality control

### Rendering report

## References

<!-- Soil site and laboratory data import: -->
<!-- ```{r} -->
<!-- if(!exists("kssl.df")){ -->
<!--   kssl.df = mdb.get(paste(dir, "All_Spectra_Access_Portable_7-7-21.mdb", sep = "")) -->
<!-- } -->
<!-- ``` -->
<!-- ```{r} -->
<!-- names(kssl.df$sample) -->
<!-- analyte.check = as.data.frame(kssl.df$analyte) -->
<!-- names(kssl.df) -->
<!-- ``` -->
<!-- ## Soil laboratory data -->
<!-- Not all soil variables have enough measurements for calibration purposes and for this reason it was set up a table containing the target variables (`OSSL_soilvars.csv`): -->
<!-- ```{r} -->
<!-- summary(as.factor(kssl.df$layer_analyte$analyte.id), maxsum = 10) -->
<!-- ``` -->
<!-- Join samples with measured soil analytics -->
<!-- ```{r} -->
<!-- kssl.y = plyr::join(kssl.df$layer_analyte[,c("lay.analyte.id", "lay.id", "lab.id", "analyte.id", "calc.value")], -->
<!--                     kssl.df$analyte[,c("analyte.id", "analyte.code", "analyte.abbrev", "uom.abbrev", "analyte.name", "analyte.desc")]) -->
<!-- kssl.y$analyte_abbrev = kssl.y$analyte.abbrev -->
<!-- ``` -->
<!-- Join samples with soil analytics calculated by some formula -->
<!-- ```{r} -->
<!-- kssl.calc = plyr::join(kssl.df$result[, c("result.id", "result.source.id", "calc.id", "lab.id", "calc.value")],  -->
<!--                        kssl.df$calc[, c("calc.id", "calc.abbrev", "calc.name", "uom.abbrev", "calc.desc", "calc.algorithm.desc")]) -->
<!-- ``` -->
<!-- The target soil variables were defined in the `OSSL_soilvars.csv` table: -->
<!-- ```{r} -->
<!-- analyte = read.csv(paste0(dir, "OSSL_soilvars.csv")) -->
<!-- str(analyte$analyte.id) -->
<!-- soil.mv = analyte$analyte_abbrev[which(!analyte$analyte.id %in% levels(as.factor(kssl.y$analyte.id)))] -->
<!-- soil.mv -->
<!-- ``` -->
<!-- Copy values of selected derived variables: -->
<!-- ```{r} -->
<!-- calc.lst = lapply(soil.mv[1:6], function(i){ -->
<!--   calc.id.tmp <- as.integer(strsplit(analyte[analyte$analyte_abbrev==i,"calc.id"], ", ")[[1]]);  -->
<!--   calc.df <- kssl.calc[kssl.calc$calc.id %in% calc.id.tmp,]; -->
<!--   calc.df$analyte_abbrev <- i; return(calc.df)}) -->
<!-- calc.lst <- do.call(rbind, calc.lst) -->
<!-- ## layer ID different name: -->
<!-- calc.lst$lay.id = calc.lst$result.source.id -->
<!-- calc.lst$analyte.name = calc.lst$calc.name  -->
<!-- str(calc.lst[,c("analyte_abbrev", "calc.value", "lay.id", "analyte.name")]) -->
<!-- ``` -->
<!-- To identify how many samples the KSSL library have for each soil attribute. -->
<!-- ```{r} -->
<!-- sm = summary(as.factor(kssl.y$analyte.id), maxsum = length(levels(as.factor(kssl.y$analyte.id)))) -->
<!-- analyte$count = plyr::join(analyte["analyte.id"], data.frame(count=sm, analyte.id=attr(sm, "names")))$count -->
<!-- #analyte = analyte[, c("ossl_code", "analyte.id", "analyte.abbrev", "name", "uom_abbrev", "method_Orig", "priority", "count")] -->
<!-- #write.csv(analyte, paste0(dir, "KSSL_analyte_count.csv")) -->
<!-- ``` -->
<!-- Bind measured and calculated values: -->
<!-- ```{r} -->
<!-- kssl.yl = rbind(kssl.y[,c("lay.id", "lab.id", "analyte_abbrev", "analyte.name", "calc.value")], calc.lst[,c("lay.id", "lab.id", "analyte_abbrev", "analyte.name", "calc.value")]) -->
<!-- # Selecting the target variables -->
<!-- sel.col = paste(analyte$analyte_abbrev) -->
<!-- str(sel.col) -->
<!-- kssl.yl = kssl.yl[which(kssl.yl$analyte_abbrev %in% sel.col),]  -->
<!-- levels(as.factor(kssl.yl$analyte_abbrev)) -->
<!-- kssl.yl$ossl_code = plyr::join(kssl.yl["analyte_abbrev"], analyte[c("analyte_abbrev", "ossl_code")], match = "first")$ossl_code -->
<!-- #summary(as.factor(kssl.yl$ossl_code)) -->
<!-- ``` -->
<!-- Convert long table to wide so that each soil variable gets unique column and,  -->
<!-- the mean and mode could be calculated for n replicates/duplicates. -->
<!-- (note: the most computational / time-consuming step usually): -->
<!-- ```{r} -->
<!-- kssl.yl$calc.value = as.numeric(kssl.yl$calc.value) -->
<!-- kssl.yw = data.table::dcast(as.data.table(kssl.yl), formula = lay.id ~ ossl_code, value.var = "calc.value", fun.aggregate = mean) -->
<!-- dim(kssl.yw) # 95849 observations of 54 variables -->
<!-- ``` -->
<!-- Check for duplicates: -->
<!-- ```{r} -->
<!-- sum(duplicated(kssl.yw$lay.id)) # It should be no duplicates -->
<!-- ``` -->
<!-- Drop any measurements that do not match `MIR spectra` table: -->
<!-- (Note: There were 30,977 observations that did not match up) -->
<!-- ```{r} -->
<!-- sel.mis0 = which(!kssl.yw$lay.id %in% kssl.x$lay.id) -->
<!-- str(sel.mis0)  -->
<!-- kssl.yw = kssl.yw[-sel.mis0,] -->
<!-- # The final soil analytes table -->
<!-- ``` -->
<!-- Clean up values: -->
<!-- ```{r} -->
<!-- kssl.yw$id.layer_local_c = kssl.yw$lay.id -->
<!-- kssl.yw = as.data.frame(kssl.yw) -->
<!-- ## clean-up: -->
<!-- for(j in names(kssl.yw)){ -->
<!--   if(is.numeric(kssl.yw[,j])){ -->
<!--     kssl.yw[,j] = replace(kssl.yw[,j], is.infinite(kssl.yw[,j]) | is.nan(kssl.yw[,j]), NA) -->
<!--   } -->
<!-- } -->
<!-- #kssl.yw = do.call(data.frame, lapply(kssl.yw, function(x) replace(x, is.infinite(x) | is.nan(x), NA))) -->
<!-- ``` -->
<!-- Exporting the table: -->
<!-- ```{r} -->
<!-- kssl.yw$sample.contact.name_utf8_txt = 'Scarlett Murphy' -->
<!-- kssl.yw$sample.contact.email_ietf_email = 'Scarlett.Murphy@usda.gov' -->
<!-- kssl.yw$id.layer_uuid_c = openssl::md5(make.unique(paste0(kssl.yw$id.layer_local_c))) -->
<!-- x.na = soilab.name[which(!soilab.name %in% names(kssl.yw))] -->
<!-- x.na -->
<!-- if(length(x.na)>0){ for(i in x.na){ kssl.yw[,i] <- NA } } -->
<!-- soilab.rds = paste0(dir, "ossl_soillab_v1.rds") -->
<!-- if(!file.exists(soilab.rds)){ -->
<!--   saveRDS.gz(kssl.yw[,soilab.name], soilab.rds) -->
<!-- } -->
<!-- ``` -->
<!-- ## Soil site data -->
<!-- Soil site information includes coordinates, soil site and soil horizon  -->
<!-- description information: -->
<!-- ```{r} -->
<!-- kssl.site = plyr::join_all(list(kssl.df$lims_site, kssl.df$layer, kssl.df$lims_pedon), by="lims.site.id") -->
<!-- kssl.site$pedon.taxa_usda_c = plyr::join(kssl.site[c("lims.pedon.id")], kssl.df$lims_ped_tax_hist[c("lims.pedon.id", "taxonomic.classification.name")], match = "first")$taxonomic.classification.name -->
<!-- dim(kssl.site) -->
<!-- ``` -->
<!-- Convert coordinates to WGS coordinates: -->
<!-- ```{r} -->
<!-- library(sp) -->
<!-- datum.ls = summary(as.factor(kssl.site$horizontal.datum.name)) -->
<!-- datum.ls -->
<!-- xy.lon = kssl.site$longitude.degrees + kssl.site$longitude.minutes/60 + kssl.site$longitude.seconds/3600 -->
<!-- #summary(as.factor(kssl.site$latitude.direction)) -->
<!-- #summary(as.factor(kssl.site$longitude.direction)) -->
<!-- xy.lat = kssl.site$latitude.degrees + kssl.site$latitude.minutes/60 + kssl.site$latitude.seconds/3600 -->
<!-- kssl.site$longitude_wgs84_dd = ifelse(kssl.site$longitude.direction=="east", xy.lon, -xy.lon) -->
<!-- kssl.site$latitude_wgs84_dd = ifelse(kssl.site$latitude.direction=="south", -xy.lat, xy.lat) -->
<!-- ## https://epsg.io/4269 -->
<!-- for(k in c("NAD83")){ ## "NAD27" -->
<!--   sel.gps = which(kssl.site$horizontal.datum.name %in% k) -->
<!--   if(length(sel.gps)>0){ -->
<!--     kssl.xy = kssl.site[sel.gps, c("lay.id", "longitude_wgs84_dd", "latitude_wgs84_dd")] -->
<!--     kssl.xy = kssl.xy[!is.na(kssl.xy$longitude_wgs84_dd)&!is.na(kssl.xy$latitude_wgs84_dd),] -->
<!--     coordinates(kssl.xy) = ~ longitude_wgs84_dd + latitude_wgs84_dd -->
<!--     if(k=="NAD83"){  -->
<!--       proj4string(kssl.xy) <- CRS("+proj=longlat +ellps=GRS80") -->
<!--     } else { -->
<!--       proj4string(kssl.xy) <- CRS("+proj=longlat +ellps=clrk66 +datum=NAD27 +no_defs") -->
<!--     } -->
<!--     kssl.xy.ll = spTransform(kssl.xy, CRS("+proj=longlat +ellps=WGS84 +datum=WGS84")) -->
<!--     ri = which(kssl.site$lay.id %in% kssl.xy.ll$lay.id) -->
<!--     kssl.site[ri,"longitude_wgs84_dd"] = kssl.xy.ll@coords[,1] -->
<!--     kssl.site[ri,"latitude_wgs84_dd"] = kssl.xy.ll@coords[,2] -->
<!--   } -->
<!-- } -->
<!-- #plot(kssl.site[,c("longitude_wgs84_dd","latitude_wgs84_dd")]) -->
<!-- ## Discarded datum Unknown based on GRS80 ellipsoid in CRS definition -->
<!-- ``` -->
<!-- Add the [Open Location Code](https://cran.r-project.org/web/packages/olctools/vignettes/Introduction_to_olctools.html) to the site table: -->
<!-- ```{r} -->
<!-- kssl.site$id.location_olc_c = olctools::encode_olc(kssl.site$latitude_wgs84_dd, kssl.site$longitude_wgs84_dd, 10) -->
<!-- kssl.site$id.location_olc_c[1:5] -->
<!-- ``` -->
<!-- Add the [Universal Unique Identifier](https://cran.r-project.org/web/packages/uuid/) (UUI): -->
<!-- ```{r} -->
<!-- kssl.site$id.layer_uuid_c = plyr::join(kssl.site["lay.id"], kssl.yw[,c("lay.id", "id.layer_uuid_c")])$id.layer_uuid_c  -->
<!-- ``` -->
<!-- Add observation date from the project fiscal year (only year available): -->
<!-- ```{r} -->
<!-- kssl.site$observation.date.begin_iso.8601_yyyy.mm.dd = as.Date(paste(plyr::join(kssl.site["proj.id"], kssl.df$project[,c("proj.id", "fiscal.year")])$fiscal.year), format="%Y") -->
<!-- kssl.site$observation.date.end_iso.8601_yyyy.mm.dd = kssl.site$observation.date.begin_iso.8601_yyyy.mm.dd -->
<!-- kssl.site$location.address_utf8_txt = plyr::join(kssl.site["proj.id"], kssl.df$project[,c("proj.id", "submit.proj.name")])$submit.proj.name -->
<!-- ``` -->
<!-- Missing coordinates can be derived from county names: -->
<!-- ```{r} -->
<!-- site_id.df = plyr::join(kssl.site[,c("lay.id","lims.site.id","longitude_wgs84_dd","latitude_wgs84_dd")], plyr::join_all(list(kssl.df$centroid, kssl.df$area, kssl.df$site_area_overlap)), match="first") -->
<!-- kssl.site$longitude_wgs84_dd = ifelse(is.na(kssl.site$longitude_wgs84_dd), site_id.df$long.xcntr, kssl.site$longitude_wgs84_dd) -->
<!-- kssl.site$latitude_wgs84_dd = ifelse(is.na(kssl.site$latitude_wgs84_dd), site_id.df$lat.ycntr, kssl.site$latitude_wgs84_dd) -->
<!-- ``` -->
<!-- We assume that the location accuracy for centroid coordinates (`long.xcntr` and `lat.ycntr`) corresponds to the size of the county, otherwise it is 30-m i.e. standard GPS location accuracy: -->
<!-- ```{r} -->
<!-- if(!exists("usa.county")){ -->
<!--   usa.county = rgdal::readOGR(paste0(dir, "tl_2017_us_county/tl_2017_us_county.shp"))   -->
<!-- } -->
<!-- length(usa.county) -->
<!-- ## 3233 counties -->
<!-- usa.county$fips.code = paste0(usa.county$STATEFP, usa.county$COUNTYFP) -->
<!-- usa.county@data[usa.county$fips.code=="17099",] -->
<!-- kssl.site$location.error_any_m = 30 -->
<!-- site_id.df$location.error_any_m = sqrt(as.numeric(plyr::join(site_id.df["fips.code"], usa.county@data[,c("fips.code","ALAND")])$ALAND)/pi) -->
<!-- kssl.site$location.error_any_m = ifelse(is.na(kssl.site$latitude.seconds), site_id.df$location.error_any_m, kssl.site$location.error_any_m) -->
<!-- summary(kssl.site$location.error_any_m) -->
<!-- #head(kssl.site, 5) -->
<!-- #colnames(kssl.site) -->
<!-- ``` -->
<!-- Summarizing the soil site info: -->
<!-- ```{r} -->
<!-- summary(as.factor(ifelse(kssl.site$location.error_any_m==30, "GPS", "County centroids"))) -->
<!-- kssl.site$location.method_any_c = ifelse(kssl.site$location.error_any_m==30, "GPS", "County centroids") -->
<!-- ``` -->
<!-- Remove all rows that do not match `MIR spectra` table (this is a Soil Spectral DB so spectra should be available): -->
<!-- ```{r} -->
<!-- sel.mis = which(!kssl.site$lay.id %in% kssl.x$lay.id) -->
<!-- str(sel.mis) -->
<!-- ## 33123 -->
<!-- kssl.sitef = kssl.site[-sel.mis,] -->
<!-- ``` -->
<!-- Add missing columns: -->
<!-- ```{r} -->
<!-- kssl.sitef$location.country_iso.3166_c = "USA" -->
<!-- kssl.sitef$id.layer_local_c = kssl.sitef$lay.id -->
<!-- kssl.sitef$observation.ogc.schema.title_ogc_txt = 'Open Soil Spectroscopy Library' -->
<!-- kssl.sitef$observation.ogc.schema_idn_url = 'https://soilspectroscopy.github.io' -->
<!-- kssl.sitef$surveyor.title_utf8_txt = 'USDA Natural Resource Conservation Service (NRCS) staff' -->
<!-- kssl.sitef$surveyor.contact_ietf_email = 'rich.ferguson@usda.gov' -->
<!-- kssl.sitef$surveyor.address_utf8_txt = 'USDA-NRCS-NSSC, Federal Building, Room 152, Mail Stop, 100 Centennial Mall North, Lincoln, NE' -->
<!-- kssl.sitef$dataset.title_utf8_txt = 'Kellogg Soil Survey Laboratory database' -->
<!-- kssl.sitef$dataset.owner_utf8_txt = 'USDA, Soil and Plant Science Division, National Soil Survey Center' -->
<!-- kssl.sitef$dataset.code_ascii_c = 'KSSL.SSL' -->
<!-- kssl.sitef$dataset.address_idn_url = 'https://ncsslabdatamart.sc.egov.usda.gov/' -->
<!-- kssl.sitef$dataset.license.title_ascii_txt = 'CC-BY' -->
<!-- kssl.sitef$dataset.license.address_idn_url = 'https://ncsslabdatamart.sc.egov.usda.gov/datause.aspx' -->
<!-- kssl.sitef$dataset.doi_idf_url = '' -->
<!-- kssl.sitef$dataset.contact.name_utf8_txt = 'Scarlett Murphy' -->
<!-- kssl.sitef$dataset.contact_ietf_email = 'Scarlett.Murphy@usda.gov' -->
<!-- kssl.sitef$id.project_ascii_c = kssl.sitef$proj.id -->
<!-- kssl.sitef$layer.sequence_usda_uint16 = '' -->
<!-- kssl.sitef$layer.type_usda_c = '' -->
<!-- kssl.sitef$layer.field.label_any_c = '' -->
<!-- kssl.sitef$layer.upper.depth_usda_cm = kssl.sitef$lay.depth.to.top -->
<!-- kssl.sitef$layer.lower.depth_usda_cm = kssl.sitef$lay.depth.to.bottom -->
<!-- kssl.sitef$horizon.designation_usda_c = paste(kssl.sitef$horz.desgn.master, kssl.sitef$horz.desgn.master.prime, kssl.sitef$horz.desgn.vertical.subdvn, sep="_") -->
<!-- kssl.sitef$horizon.designation.discontinuity_usda_c = kssl.sitef$horz.desgn.discontinuity -->
<!-- kssl.sitef$layer.texture_usda_c = kssl.sitef$texture.description -->
<!-- kssl.sitef$layer.sequence_usda_uint16 = kssl.sitef$lay.rpt.seq.num -->
<!-- kssl.sitef$id.user.site_ascii_c = kssl.sitef$user.site.id -->
<!-- ``` -->
<!-- Export the final soil site tables: -->
<!-- ```{r} -->
<!-- x.na = site.name[which(!site.name %in% names(kssl.sitef))] -->
<!-- x.na -->
<!-- if(length(x.na)>0){ for(i in x.na){ kssl.sitef[,i] <- NA } } -->
<!-- #str(kssl.sitef[,site.name]) -->
<!-- #summary(is.na(kssl.sitef$longitude_wgs84_dd)) -->
<!-- summary(as.factor(kssl.sitef$location.method_any_c)) -->
<!-- #County centroids              GPS             NA's  -->
<!-- #           67600            40948             8670 -->
<!-- site.rds = paste0(dir, "ossl_soilsite_v1.rds") -->
<!-- if(!file.exists(site.rds)){ -->
<!--   saveRDS.gz(kssl.sitef[,site.name], site.rds) -->
<!-- } -->
<!-- ``` -->
<!-- ## Mid-infrared spectroscopy data -->
<!-- Mid-infrared (MIR) soil spectroscopy raw data: -->
<!-- ```{r, eval=FALSE} -->
<!-- kssl.x = vroom::vroom(paste0(dir, "KSSL_MIR_spectra.csv")) -->
<!-- dim(kssl.x) -->
<!-- summary(kssl.x$`632`) -->
<!-- kssl.meta = vroom::vroom(paste0(dir, "KSSL_MIR_spectra_metadata.csv")) -->
<!-- str(which(!kssl.x$sample_id %in% kssl.meta$sample_id)) -->
<!-- #str(grep(kssl.x$sample_id, kssl.meta$sample_id)) -->
<!-- ## multiple matches -->
<!-- ## multiple dates: -->
<!-- kssl.meta$MeasurementsDateStart = as.Date(sapply(paste(kssl.meta$date_time_sm), function(i){strsplit(i, ";")[[1]][1]})) -->
<!-- kssl.meta$MeasurementsDateEnd = as.Date(sapply(paste(kssl.meta$date_time_sm), function(i){rev(strsplit(i, ";")[[1]])[1]})) -->
<!-- dim(kssl.x) -->
<!-- ``` -->
<!-- Add the [Universal Unique Identifier](https://cran.r-project.org/web/packages/uuid/) (UUI): -->
<!-- ```{r} -->
<!-- kssl.x$id.scan_uuid_c = openssl::md5(make.unique(paste0("KSSL.SSL.MIR", kssl.x$sample_id))) -->
<!-- ``` -->
<!-- For MIR drop the "XF" = different preparation method spectra scans. -->
<!-- The column names require some adjustments: -->
<!-- ```{r} -->
<!-- kssl.x$smp.id = substr(kssl.x$sample_id, 1, nchar(kssl.x$sample_id)-2) -->
<!-- str(kssl.x$smp.id) -->
<!-- length(labels(as.factor(unique(kssl.x$smp.id)))) -->
<!-- kssl.x$lay.id = plyr::join(kssl.x[,c("sample_id","smp.id")], kssl.df$sample, by="smp.id", match = "first")$lay.id -->
<!-- length(labels(as.factor(unique(kssl.x$lay.id)))) -->
<!-- ## 69,931 -->
<!-- ``` -->
<!-- Select final columns of interest and export soil spectra table: -->
<!-- ```{r} -->
<!-- sel.d = grep("XF", kssl.x$sample_id, ignore.case = FALSE) -->
<!-- str(sel.d) -->
<!-- sel.xs = unique(c(grep("XS", kssl.x$sample_id), grep("XN", kssl.x$sample_id))) -->
<!-- sel.abs = names(kssl.x)[-which(names(kssl.x) %in% c("id.scan_uuid_c", "lay.id", "smp.id", "sample_id"))] -->
<!-- ## 1699 -->
<!-- kssl.abs = as.data.frame(kssl.x)[sel.xs, c("id.scan_uuid_c", "lay.id", "smp.id", sel.abs)] -->
<!-- dim(kssl.abs) -->
<!-- ## 69,864  1704 -->
<!-- ``` -->
<!-- Small number of rows (77) are duplicates: -->
<!-- ```{r} -->
<!-- sum(duplicated(kssl.abs$lay.id)) -->
<!-- ``` -->
<!-- Original spectrum range from 4000 to 603 cm-1 with window size of ~1-2 cm-1. -->
<!-- The absorbance values can range from 0 (reflectance = 1) to 3 (reflectance = 0.001) highlighting  -->
<!-- that is not common in soils absorbance above 3. This means the electromagnetic energy (light)  -->
<!-- blocked by the sample is 99.9% when absorbance value is 3.  -->
<!-- Detect all values out of range: -->
<!-- ```{r} -->
<!-- wav.mir = as.numeric(gsub("X", "", sel.abs)) # Get wavelength only -->
<!-- summary(wav.mir) -->
<!-- # Creating a matrix with only spectral values -->
<!-- kssl.mir.spec = as.matrix(kssl.abs[,sel.abs]) -->
<!-- colnames(kssl.mir.spec) = wav.mir -->
<!-- rownames(kssl.mir.spec) = kssl.abs$id.scan_uuid_c -->
<!-- ## Detect and quantify any problems: -->
<!-- library(doMC) -->
<!-- cl = makeCluster(mc <- getOption("cl.cores", 80)) -->
<!-- samples.na.gaps = parallel::parRapply(cl, kssl.mir.spec, FUN=function(j){ round(100*sum(is.na(j))/length(j), 3)})  -->
<!-- samples.negative = parallel::parRapply(cl, kssl.mir.spec, FUN=function(j){ round(100*sum(j <= 0, na.rm=TRUE)/length(j), 3) }) -->
<!-- sum(samples.negative>0) -->
<!-- samples.extreme = parallel::parRapply(cl, kssl.mir.spec, FUN=function(j){ round(100*sum(j >= 3, na.rm=TRUE)/length(j), 3) }) -->
<!-- sum(samples.extreme>0) -->
<!-- stopCluster(cl) -->
<!-- ``` -->
<!-- About 1% of scans have problems either negative or extreme values. -->
<!-- Resampling the MIR spectra from the original window size to 2 cm-1 in `kssl.abs`. -->
<!-- This operation can be time-consuming: -->
<!-- ```{r} -->
<!-- ## stack all values -->
<!-- kssl.mir = prospectr::resample(kssl.mir.spec, wav.mir, seq(600, 4000, 2), interpol = "spline")  -->
<!-- ## Wavelength by 2 cm-1 -->
<!-- kssl.mir = round(as.data.frame(kssl.mir)*1000) -->
<!-- mir.n = paste0("scan_mir.", seq(600, 4000, 2), "_abs") -->
<!-- colnames(kssl.mir) = mir.n -->
<!-- dim(kssl.mir) -->
<!-- ``` -->
<!-- Plotting MIR spectra to check: -->
<!-- ```{r} -->
<!-- #str(names(kssl.mir)) -->
<!-- kssl.mir$id.scan_uuid_c = rownames(kssl.mir) -->
<!-- matplot(y=as.vector(t(kssl.mir[5700,mir.n])), x=seq(600, 4000, 2), -->
<!--         ylim = c(0,3000), -->
<!--         type = 'l',  -->
<!--         xlab = "Wavelength",  -->
<!--         ylab = "Absorbance" -->
<!--         ) -->
<!-- ``` -->
<!-- Export final MIR table: -->
<!-- ```{r} -->
<!-- kssl.mir$id.layer_local_c = plyr::join(kssl.mir["id.scan_uuid_c"], kssl.abs[c("id.scan_uuid_c","lay.id")])$lay.id -->
<!-- str(kssl.mir$id.layer_local_c) -->
<!-- kssl.mir$id.layer_uuid_c = plyr::join(kssl.mir["id.layer_local_c"], kssl.yw[c("id.layer_local_c","id.layer_uuid_c")], match="first")$id.layer_uuid_c -->
<!-- summary(is.na(kssl.mir$id.layer_uuid_c)) -->
<!-- ## 5126 with missing values -->
<!-- kssl.mir$id.scan_local_c = plyr::join(kssl.mir["id.scan_uuid_c"], kssl.abs[c("id.scan_uuid_c","smp.id")])$smp.id -->
<!-- kssl.mir$model.name_utf8_txt = "Bruker Vertex 70 with HTS-XT accessory" -->
<!-- kssl.mir$model.code_any_c = "Bruker_Vertex_70.HTS.XT" -->
<!-- kssl.mir$method.light.source_any_c = plyr::join(kssl.x[sel.xs,"sample_id"], kssl.meta)$beamspl -->
<!-- kssl.mir$method.preparation_any_c = "" -->
<!-- ## file names available: -->
<!-- kssl.mir$scan.file_any_c = plyr::join(kssl.x[sel.xs,"sample_id"], kssl.meta)$file_id -->
<!-- kssl.mir$scan.date.begin_iso.8601_yyyy.mm.dd = paste(plyr::join(kssl.x[sel.xs,"sample_id"], kssl.meta)$MeasurementsDateStart) #as.Date("2019-07-26") -->
<!-- kssl.mir$scan.date.end_iso.8601_yyyy.mm.dd = paste(plyr::join(kssl.x[sel.xs,"sample_id"], kssl.meta)$MeasurementsDateEnd) -->
<!-- kssl.mir$scan.license.title_ascii_txt = "CC-BY" -->
<!-- kssl.mir$scan.license.address_idn_url = "https://ncsslabdatamart.sc.egov.usda.gov/datause.aspx" -->
<!-- kssl.mir$scan.doi_idf_c = "" -->
<!-- kssl.mir$scan.contact.name_utf8_txt = "Scarlett Murphy" -->
<!-- kssl.mir$scan.contact.email_ietf_email = "Scarlett.Murphy@usda.gov" -->
<!-- kssl.mir$scan.mir.nafreq_ossl_pct = samples.na.gaps -->
<!-- kssl.mir$scan.mir.negfreq_ossl_pct = samples.negative -->
<!-- kssl.mir$scan.mir.extfreq_ossl_pct = samples.extreme -->
<!-- ``` -->
<!-- Save to RDS file: -->
<!-- ```{r} -->
<!-- x.na = mir.name[which(!mir.name %in% names(kssl.mir))] -->
<!-- if(length(x.na)>0){ for(i in x.na){ kssl.mir[,i] <- NA } } -->
<!-- str(kssl.mir[,mir.name[1:24]]) -->
<!-- mir.rds = paste0(dir, "ossl_mir_v1.rds") -->
<!-- if(!file.exists(mir.rds)){ -->
<!--   saveRDS.gz(kssl.mir[,mir.name], mir.rds) -->
<!-- } -->
<!-- #rm(kssl.mir.spec); rm(kssl.mir); rm(kssl.abs) -->
<!-- gc() -->
<!-- ``` -->
<!-- ## Visible and near-infrared spectroscopy data -->
<!-- Visible and near-infrared (VNIR) imported using `get_spectra` function from [asdreader package](https://rdrr.io/cran/asdreader/man/get_spectra.html): -->
<!-- ```{r} -->
<!-- kssl.vnir = readRDS.gz(paste0(dir, "vnir_09MAR2021.rds")) -->
<!-- #kssl.vnir = vroom::vroom(paste0(dir, "VNIR_Spectra_Library_19APR2022.csv")) -->
<!-- kssl.vnirmeta = read.csv(paste0(dir, "VNIR_Spectra_Library_meta.csv")) -->
<!-- dim(kssl.vnir) -->
<!-- ## 69,715  2162 -->
<!-- ``` -->
<!-- Detect negative values: -->
<!-- ```{r} -->
<!-- sel.vnir = grep("spec.vnir_", names(kssl.vnir)) -->
<!-- #hist(as.vector(unlist(kssl.vnir[,sel.vnir[sample.int(length(sel.vnir), 10)]])), breaks=45, main="VisNIR") -->
<!-- library(doMC) -->
<!-- cl = makeCluster(mc <- getOption("cl.cores", 80)) -->
<!-- samples0.na.gaps = parallel::parRapply(cl, kssl.vnir[,sel.vnir], FUN=function(j){ round(100*sum(is.na(j))/length(j), 3)})  -->
<!-- samples0.negative = parallel::parRapply(cl, kssl.vnir[,sel.vnir], FUN=function(j){ round(100*sum(j <= 0, na.rm=TRUE)/length(j), 3) }) -->
<!-- sum(samples0.negative>0, na.rm=TRUE) -->
<!-- samples0.extreme = parallel::parRapply(cl, kssl.vnir[,sel.vnir], FUN=function(j){ round(100*sum(j >= 1, na.rm=TRUE)/length(j), 3) }) -->
<!-- sum(samples0.extreme>0, na.rm=TRUE) -->
<!-- stopCluster(cl) -->
<!-- kssl.vnir.f = round(kssl.vnir[,sel.vnir]*100, 1) -->
<!-- vnir.s = sapply(names(kssl.vnir)[sel.vnir], function(i){ strsplit(i, "_")[[1]][2] }) -->
<!-- vnir.n = paste0("scan_visnir.", vnir.s, "_pcnt") -->
<!-- names(kssl.vnir.f) = vnir.n -->
<!-- ``` -->
<!-- Plot and check individual curves: -->
<!-- ```{r} -->
<!-- kssl.vnir.f$smp.id = kssl.vnir$smp.id -->
<!-- #str(names(kssl.vnir)) -->
<!-- matplot(y=as.vector(t(kssl.vnir.f[4700,vnir.n])), x=vnir.s, -->
<!--         ylim = c(0,60), -->
<!--         type = 'l',  -->
<!--         xlab = "Wavelength",  -->
<!--         ylab = "Reflectance" -->
<!--         ) -->
<!-- ``` -->
<!-- Adding basic columns: -->
<!-- ```{r} -->
<!-- kssl.vnir.f$id.layer_local_c = plyr::join(kssl.vnir.f[c("smp.id")], kssl.x[c("smp.id", "lay.id")], match = "first")$lay.id -->
<!-- summary(is.na(kssl.vnir.f$smp.id)) -->
<!-- kssl.vnir.f$id.scan_uuid_c = openssl::md5(make.unique(paste0("KSSL.SSL.VNIR", kssl.vnir.f$smp.id))) -->
<!-- summary(is.na(kssl.vnir.f$id.scan_uuid_c)) -->
<!-- kssl.vnir.f$id.scan_local_c = kssl.vnir.f$smp.id -->
<!-- kssl.vnir.f$id.layer_uuid_c = plyr::join(kssl.vnir.f["id.layer_local_c"], kssl.yw[c("id.layer_local_c","id.layer_uuid_c")], match="first")$id.layer_uuid_c -->
<!-- summary(is.na(kssl.vnir.f$id.layer_uuid_c)) -->
<!-- ## 34,423 missing id's -->
<!-- kssl.vnir.f$model.name_utf8_txt = "ASD Labspec 2500 with Muglight accessory" -->
<!-- kssl.vnir.f$model.code_any_c = "ASD_Labspec_2500_MA" -->
<!-- kssl.vnir.f$method.light.source_any_c = "" -->
<!-- kssl.vnir.f$method.preparation_any_c = "" -->
<!-- kssl.vnir.f$scan.file_any_c = kssl.vnir$scan.path.name -->
<!-- kssl.vnir.f$scan.date.begin_iso.8601_yyyy.mm.dd = format(as.POSIXct(kssl.vnir$scan.date, format="%d/%m/%y %H:%M:%S"), "%Y-%m-%d %H:%M:%OS") -->
<!-- kssl.vnir.f$scan.date.end_iso.8601_yyyy.mm.dd = format(as.POSIXct(kssl.vnir$scan.date, format="%d/%m/%y %H:%M:%S"), "%Y-%m-%d %H:%M:%OS") -->
<!-- kssl.vnir.f$scan.license.title_ascii_txt = "CC-BY" -->
<!-- kssl.vnir.f$scan.license.address_idn_url = "https://ncsslabdatamart.sc.egov.usda.gov/datause.aspx" -->
<!-- kssl.vnir.f$scan.doi_idf_c = "" -->
<!-- kssl.vnir.f$scan.contact.name_utf8_txt = "Scarlett Murphy" -->
<!-- kssl.vnir.f$scan.contact.email_ietf_email = "Scarlett.Murphy@usda.gov" -->
<!-- kssl.vnir.f$scan.visnir.nafreq_ossl_pct = samples0.na.gaps -->
<!-- kssl.vnir.f$scan.visnir.negfreq_ossl_pct = samples0.negative -->
<!-- kssl.vnir.f$scan.visnir.extfreq_ossl_pct = samples0.extreme -->
<!-- ``` -->
<!-- Save final table: -->
<!-- ```{r} -->
<!-- x.na = visnir.name[which(!visnir.name %in% names(kssl.vnir.f))] -->
<!-- if(length(x.na)>0){ for(i in x.na){ kssl.vnir.f[,i] <- NA } } -->
<!-- visnir.rds = paste0(dir, "ossl_visnir_v1.rds") -->
<!-- kssl.vnir.f = kssl.vnir.f[!is.na(kssl.vnir.f$smp.id),] -->
<!-- if(!file.exists(visnir.rds)){ -->
<!--   saveRDS.gz(kssl.vnir.f[,visnir.name], visnir.rds) -->
<!-- } -->
<!-- #rm(kssl.vnir) -->
<!-- ``` -->
<!-- ## Quality control -->
<!-- Check if some points don't have any spectral scans: -->
<!-- ```{r} -->
<!-- summary(is.na(kssl.mir$id.scan_uuid_c)) -->
<!-- mis.r = kssl.mir$id.layer_uuid_c %in% kssl.sitef$id.layer_uuid_c -->
<!-- summary(mis.r) -->
<!-- ## some 649 scans have no soil data -->
<!-- ``` -->
<!-- Check if now scan IDs are duplicate: -->
<!-- ```{r} -->
<!-- sum(duplicated(c(kssl.mir$id.scan_uuid_c, kssl.vnir.f$id.scan_uuid_c))) -->
<!-- ``` -->
<!-- ## Distribution of points -->
<!-- We can plot an USA map showing distribution of the sampling locations within the [USA48](https://www.openstreetmap.org/?box=yes&bbox=-124.848974,24.396308,-66.885444,49.384358#map=5/37.941/-95.867) using: -->
<!-- ```{r, kssl.pnts_sites} -->
<!-- library(maps) -->
<!-- library(ggplot2) -->
<!-- #colnames(kssl.sitef) -->
<!-- usa.xy = kssl.sitef[,c("lay.id", "id.location_olc_c", "longitude_wgs84_dd", "latitude_wgs84_dd")] -->
<!-- ## Extent: (-124.848974, 24.396308) - (-66.885444, 49.384358) -->
<!-- usa.xy = usa.xy[usa.xy$latitude_wgs84_dd>24.396308 & usa.xy$latitude_wgs84_dd<49.384358 & usa.xy$longitude_wgs84_dd < -66.885444 & usa.xy$longitude_wgs84_dd > -124.848974,] -->
<!-- plt.usa.xy = ggplot(usa.xy, aes(longitude_wgs84_dd, latitude_wgs84_dd)) + -->
<!--   borders("state") + -->
<!--   geom_point(shape=18, size=.9, color="red") + -->
<!--   scale_size_area() + -->
<!--   coord_quickmap() -->
<!-- plt.usa.xy -->
<!-- ``` -->
<!-- Fig.  1: USDA KSSL locations of sites within USA48. -->
<!-- ```{r, eval=FALSE} -->
<!-- #save.image.pigz(file=paste0(dir, "KSSL.RData"), n.cores=80) -->
<!-- #rmarkdown::render("dataset/KSSL/README.rmd") -->
<!-- ``` -->
<!-- ## References -->

<div id="refs" class="references csl-bib-body hanging-indent"
line-spacing="2">

<div id="ref-sanderman2020mid" class="csl-entry">

Sanderman, J., Savage, K., & Dangal, S. R. (2020). Mid-infrared
spectroscopy for prediction of soil health indicators in the united
states. *Soil Science Society of America Journal*, *84*(1), 251–261.
doi:[10.1002/saj2.20009](https://doi.org/10.1002/saj2.20009)

</div>

<div id="ref-wijewardane2018predicting" class="csl-entry">

Wijewardane, N. K., Ge, Y., Wills, S., & Libohova, Z. (2018). <span
class="nocase">Predicting physical and chemical properties of US soils
with a mid-infrared reflectance spectral library</span>. *Soil Science
Society of America Journal*, *82*(3), 722–731.
doi:[10.2136/sssaj2017.10.0361](https://doi.org/10.2136/sssaj2017.10.0361)

</div>

</div>
