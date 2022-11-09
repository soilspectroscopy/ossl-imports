Dataset import: The Land-Use/Cover Area Survey Soil and Spectral Library
(LUCAS)
================
Tomislav Hengl (<tom.hengl@opengeohub.org>), Leandro Parente
(<leandro.parente@opengeohub.org>), and Jose Lucas Safanelli
(<jsafanelli@woodwellclimate.org>) -
09 November, 2022



-   [LUCAS](#lucas)
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

## LUCAS

Part of: <https://github.com/soilspectroscopy>  
Project: [Soil Spectroscopy for Global
Good](https://soilspectroscopy.org)  
Last update: 2022-11-09  
Dataset:
[LUCAS.SSL](https://soilspectroscopy.github.io/ossl-manual/soil-spectroscopy-tools-and-users.html#lucas.ssl)

The Land-Use/Cover Area frame statistical Survey (LUCAS) Soil and
Spectral Library comprise topsoil information including 28 European
Union Member States in 2009 and 2015 ([Orgiazzi, Ballabio, Panagos,
Jones, & Fernández-Ugalde, 2018](#ref-orgiazzi2018lucas)). Data is
hosted by Joint Research Centre (JRC)- European Soil Data Centre
(ESDAC); dataset properties and licence are explained in detail in
<https://esdac.jrc.ec.europa.eu/projects/lucas>.

Input datasets:

-   `LUCAS.SOIL_corr.Rdata`: VNIR soil spectral reflectances (4200
    channels/ window of 0.5 nm from 400 - 2499.5 nm);
-   `LUCAS_Topsoil_2009_ESPG4326.csv`: 2009 Database with site and soil
    analytes (19,860 observations);  
-   `LUCAS_spectra_2015.rds`: VNIR soil spectral reflectances (4200
    channels/ window of 0.5 nm from 400 - 2499.5 nm);
-   `LUCAS_Topsoil_complete_2015_ESPG4326.csv`: 2015 Database with site
    and soil analytes (21,848 observations);

For the DB structure and use refer to “LUCAS Soil, the largest
expandable soil dataset for Europe: a review” contact: Arwyn Jones
[ec-esdac@jrc.ec.europa.eu](JRC).

Directory/folder path

``` r
dir = "/mnt/soilspec4gg/ossl/dataset/LUCAS/"
#load.pigz(paste0(dir, "LUCAS.RData"))
```

## Data import

### Soil site information

### Soil lab information

Run once! Original naming of soil properties, descriptions, data types,
and units. Run once and upload to Google Sheet for formatting and
integrating with the OSSL. Requires Google authentication.

``` r
gpkg.lst = list.files(dir, glob2rx("SoilAttr_*.gpkg$"), full.names = TRUE)
lucas.2009 = lapply(gpkg.lst, function(i){sf::st_read(i) %>% dplyr::as_tibble(.) %>% dplyr::select(-geom)})
lucas.2009 = Reduce(dplyr::bind_rows, lucas.2009)

lucas.2015 = readr::read_csv(paste0(dir, "/LUCAS_Topsoil_2015_20200323.csv"))

soillab.names <- lucas.2009 %>%
  names(.) %>%
  tibble::tibble(original_name = .) %>%
  dplyr::mutate(table = 'LUCAS 2009/2012; SoilAttr_*.gpkg', .before = 1) %>%
  dplyr::bind_rows({
    lucas.2015 %>%
      names(.) %>%
      tibble::tibble(original_name = .) %>%
      dplyr::mutate(table = 'LUCAS_Topsoil_2015.csv', .before = 1)
  }) %>%
  dplyr::mutate(import = '', ossl_name = '', .after = original_name) %>%
  dplyr::mutate(comment = '')

readr::write_csv(soillab.names, paste0(getwd(), "/lucas_soillab_names.csv"))

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
googlesheets4::write_sheet(upload, ss = OSSL.soildata.importing, sheet = "LUCAS")

# Checking metadata
googlesheets4::as_sheets_id(OSSL.soildata.importing)
```

### Mid-infrared spectroscopy data

### Quality control

### Rendering report

## References

<!-- ### Soil site and laboratory data import -->
<!-- Soil samples and lab results for some 19,860 in 2009 (2012): -->
<!-- ```{r} -->
<!-- gpkg.lst = list.files(dir, glob2rx("SoilAttr_*.gpkg$"), full.names = TRUE) -->
<!-- df.2009 = lapply(gpkg.lst, function(i){as.data.frame(readOGR(i))}) -->
<!-- df.2009 = plyr::rbind.fill(df.2009) -->
<!-- str(df.2009) -->
<!-- ``` -->
<!-- Harmonize values: -->
<!-- ```{r} -->
<!-- in2009.name = c("coarse", "clay", "silt", "sand", "pHinH2O", "pHinCaCl2", "OC", "CaCO3", "N",  -->
<!--               "P", "K", "CEC", "coords.x1", "coords.x2") -->
<!-- df.2009w = as.data.frame(df.2009[,in2009.name]) -->
<!-- out2009.name = c("wpg2_usda.3a2_wpct", "clay.tot_usda.3a1_wpct", "silt.tot_usda.3a1_wpct", "sand.tot_usda.3a1_wpct", -->
<!--                  "ph.h2o_usda.4c1_index", "ph.cacl2_usda.4c1_index", "oc_usda.calc_wpct", "caco3_usda.4e1_wpct",  -->
<!--                  "n.tot_usda.4h2_wpct", "p.ext_usda.4d6_mgkg", "k.ext_usda.4d6_mgkg", "cec.ext_usda.4b1_cmolkg", -->
<!--                  "longitude_wgs84_dd", "latitude_wgs84_dd") -->
<!-- ## compare values -->
<!-- summary(as.numeric(df.2009w$OC)) -->
<!-- fun.lst = as.list(rep("ifelse(as.numeric(x)<0, NA, as.numeric(x))", length(in2009.name))) -->
<!-- fun.lst[[which(in2009.name=="coarse")]] = "ifelse(is.na(as.numeric(x)), 0, as.numeric(x))" -->
<!-- fun.lst[[which(in2009.name=="clay")]] = "ifelse(as.numeric(x)<0, NA, as.numeric(x))" -->
<!-- fun.lst[[which(in2009.name=="sand")]] = "ifelse(as.numeric(x)<0, NA, as.numeric(x))" -->
<!-- fun.lst[[which(in2009.name=="silt")]] = "ifelse(as.numeric(x)<0, NA, as.numeric(x))" -->
<!-- fun.lst[[which(in2009.name=="OC")]] = "ifelse(as.numeric(x)<0, NA, as.numeric(x))/10" -->
<!-- fun.lst[[which(in2009.name=="N")]] = "ifelse(as.numeric(x)<0, NA, as.numeric(x))/10" -->
<!-- fun.lst[[which(in2015.name=="coords.x1")]] = "as.numeric(x)" -->
<!-- fun.lst[[which(in2015.name=="coords.x2")]] = "as.numeric(x)" -->
<!-- ## save translation rules: -->
<!-- #View(data.frame(in2009.name, out2009.name, unlist(fun.lst))) -->
<!-- write.csv(data.frame(in2009.name, out2009.name, unlist(fun.lst)), "./lucas2009_soilab_transvalues.csv") -->
<!-- df.2009w = transvalues(df.2009w, out2009.name, in2009.name, fun.lst) -->
<!-- df.2009w$id.layer_local_c = paste0("2009.", df.2009$POINT_ID) -->
<!-- df.2009w$sample.doi_idf_c = "10.2788/97922" -->
<!-- df.2009w$observation.date.begin_iso.8601_yyyy.mm.dd = as.Date("2009-05-01") -->
<!-- df.2009w$observation.date.end_iso.8601_yyyy.mm.dd = as.Date("2012-08-01") -->
<!-- ``` -->
<!-- Soils samples 21,859 points in 2015. -->
<!-- ```{r, eval=FALSE} -->
<!-- df.2015 = vroom::vroom(paste(dir, "LUCAS_Topsoil_2015_20200323.csv", sep = "")) -->
<!-- #head(df.2015) -->
<!-- v.2015 = readOGR(paste0(dir, "LUCAS_Topsoil_2015_20200323.shp")) -->
<!-- df.2015$coords.x1 = plyr::join(df.2015["Point_ID"], as.data.frame(v.2015))$coords.x1 -->
<!-- df.2015$coords.x2 = plyr::join(df.2015["Point_ID"], as.data.frame(v.2015))$coords.x2 -->
<!-- ``` -->
<!-- Harmonize values: -->
<!-- ```{r} -->
<!-- in2015.name = c("Coarse", "Clay", "Silt", "Sand", "pH(H2O)", "pH(CaCl2)", "OC", "CaCO3", "N",  -->
<!--               "P", "K", "EC", "coords.x1", "coords.x2") -->
<!-- df.2015w = as.data.frame(df.2015[,in2015.name]) -->
<!-- out2015.name = c("wpg2_usda.3a2_wpct", "clay.tot_usda.3a1_wpct", "silt.tot_usda.3a1_wpct", "sand.tot_usda.3a1_wpct", -->
<!--                  "ph.h2o_usda.4c1_index", "ph.cacl2_usda.4c1_index", "oc_usda.calc_wpct", "caco3_usda.4e1_wpct",  -->
<!--                  "n.tot_usda.4h2_wpct", "p.ext_usda.4d6_mgkg", "k.ext_usda.4d6_mgkg", "ec.w_usda.4f1_dsm", -->
<!--                  "longitude_wgs84_dd", "latitude_wgs84_dd") -->
<!-- ## compare values -->
<!-- summary(as.numeric(df.2015w$OC)) -->
<!-- fun2.lst = as.list(rep("ifelse(as.numeric(x)<0, NA, as.numeric(x))", length(in2015.name))) -->
<!-- fun2.lst[[which(in2015.name=="Coarse")]] = "ifelse(is.na(as.numeric(x)), 0, as.numeric(x))" -->
<!-- fun2.lst[[which(in2015.name=="Clay")]] = "ifelse(as.numeric(x)<0, NA, as.numeric(x))" -->
<!-- fun2.lst[[which(in2015.name=="Sand")]] = "ifelse(as.numeric(x)<0, NA, as.numeric(x))" -->
<!-- fun2.lst[[which(in2015.name=="Silt")]] = "ifelse(as.numeric(x)<0, NA, as.numeric(x))" -->
<!-- fun2.lst[[which(in2015.name=="OC")]] = "ifelse(as.numeric(x)<0, NA, as.numeric(x))/10" -->
<!-- fun2.lst[[which(in2015.name=="N")]] = "ifelse(as.numeric(x)<0, NA, as.numeric(x))/10" -->
<!-- fun2.lst[[which(in2015.name=="EC")]] = "ifelse(as.numeric(x)<0, NA, as.numeric(x))/100" -->
<!-- fun2.lst[[which(in2015.name=="coords.x1")]] = "as.numeric(x)" -->
<!-- fun2.lst[[which(in2015.name=="coords.x2")]] = "as.numeric(x)" -->
<!-- ## save translation rules: -->
<!-- #View(data.frame(in2015.name, out2015.name, unlist(fun2.lst))) -->
<!-- write.csv(data.frame(in2015.name, out2015.name, unlist(fun2.lst)), "./lucas2015_soilab_transvalues.csv") -->
<!-- df.2015w = transvalues(df.2015w, out2015.name, in2015.name, fun2.lst) -->
<!-- df.2015w$id.layer_local_c = paste0("2015.", df.2015$Point_ID) -->
<!-- df.2015w$sample.doi_idf_c = "10.1111/ejss.12499" -->
<!-- df.2015w$observation.date.begin_iso.8601_yyyy.mm.dd = as.Date("2015-03-01") -->
<!-- df.2015w$observation.date.end_iso.8601_yyyy.mm.dd = as.Date("2015-10-01") -->
<!-- #df.2015$WR_ID = paste(round(df.2015$coords.x1, 2), round(df.2015$coords.x2, 2), sep="_") -->
<!-- ``` -->
<!-- #### Soil lab information -->
<!-- Bind two datasets: -->
<!-- ```{r} -->
<!-- lucas.soil = plyr::rbind.fill(df.2009w, df.2015w) -->
<!-- lucas.soil$id.layer_uuid_c = openssl::md5(make.unique(paste0("LUCAS", lucas.soil$id.layer_local_c))) -->
<!-- ``` -->
<!-- Exporting the table: -->
<!-- ```{r} -->
<!-- lucas.soil$sample.contact.name_utf8_txt = "ESDAC - European Commission" -->
<!-- lucas.soil$sample.contact.email_ietf_email = "ec-esdac@jrc.ec.europa.eu" -->
<!-- x.na = soilab.name[which(!soilab.name %in% names(lucas.soil))] -->
<!-- if(length(x.na)>0){ for(i in x.na){ lucas.soil[,i] <- NA } } -->
<!-- soilab.rds = paste0(dir, "ossl_soillab_v1.rds") -->
<!-- if(!file.exists(soilab.rds)){ -->
<!--   saveRDS.gz(lucas.soil[,soilab.name], soilab.rds) -->
<!-- } -->
<!-- ``` -->
<!-- #### Soil site information -->
<!-- Add the [Open Location Code](https://cran.r-project.org/web/packages/olctools/vignettes/Introduction_to_olctools.html) to the site table: -->
<!-- ```{r} -->
<!-- lucas.site = lucas.soil[,c("longitude_wgs84_dd", "latitude_wgs84_dd", "id.layer_uuid_c", "id.layer_local_c", "sample.doi_idf_c", "observation.date.begin_iso.8601_yyyy.mm.dd", "observation.date.end_iso.8601_yyyy.mm.dd")] -->
<!-- ## degrade location accuracy +/-500m so we can share the points -->
<!-- lucas.site$longitude_wgs84_dd = lucas.site$longitude_wgs84_dd + rnorm(nrow(lucas.site), 0, 0.005) -->
<!-- lucas.site$latitude_wgs84_dd = lucas.site$latitude_wgs84_dd + rnorm(nrow(lucas.site), 0, 0.005) -->
<!-- lucas.site$location.method_any_c = "Degraded coordinates" -->
<!-- lucas.site$location.error_any_m = 1000 -->
<!-- lucas.site$id.location_olc_c = olctools::encode_olc(lucas.site$latitude_wgs84_dd, lucas.site$longitude_wgs84_dd, 10) -->
<!-- #colnames(lucas.site) -->
<!-- lucas.site$observation.ogc.schema.title_ogc_txt = 'Open Soil Spectroscopy Library' -->
<!-- lucas.site$observation.ogc.schema_idn_url = 'https://soilspectroscopy.github.io' -->
<!-- lucas.site$dataset.title_utf8_txt = "LUCAS 2009, 2015 top-soil data" -->
<!-- lucas.site$dataset.doi_idf_c = "10.1111/ejss.12499" -->
<!-- lucas.site$surveyor.address_utf8_txt = "" -->
<!-- lucas.site$layer.upper.depth_usda_cm = 0 -->
<!-- lucas.site$layer.lower.depth_usda_cm = 20 -->
<!-- lucas.site$dataset.code_ascii_c = "LUCAS.SSL" -->
<!-- lucas.site$dataset.address_idn_url = "https://esdac.jrc.ec.europa.eu/resource-type/soil-point-data" -->
<!-- lucas.site$dataset.owner_utf8_txt = "European Soil Data Centre (ESDAC), esdac.jrc.ec.europa.eu, European Commission, Joint Research Centre" -->
<!-- lucas.site$surveyor.title_utf8_txt = "" -->
<!-- lucas.site$dataset.license.title_ascii_txt = "JRC License Agreement" -->
<!-- lucas.site$dataset.license.address_idn_url = "https://esdac.jrc.ec.europa.eu/resource-type/soil-point-data" -->
<!-- lucas.site$surveyor.contact_ietf_email = "ec-esdac@jrc.ec.europa.eu" -->
<!-- lucas.site$dataset.contact.name_utf8_txt = "ESDAC - European Commission" -->
<!-- lucas.site$dataset.contact_ietf_email = "ec-esdac@jrc.ec.europa.eu" -->
<!-- lucas.site$id.project_ascii_c = "Land Use and Coverage Area frame Survey (LUCAS)" -->
<!-- x.na = site.name[which(!site.name %in% names(lucas.site))] -->
<!-- if(length(x.na)>0){ for(i in x.na){ lucas.site[,i] <- NA } } -->
<!-- soilsite.rds = paste0(dir, "ossl_soilsite_v1.rds") -->
<!-- if(!file.exists(soilsite.rds)){ -->
<!--   saveRDS.gz(lucas.site[,site.name], soilsite.rds) -->
<!--   write.csv(lucas.site[,site.name], paste0(dir, "ossl_soilsite_v1.csv")) -->
<!-- } -->
<!-- ``` -->
<!-- ### Visible and near-infrared (VNIR) spectroscopy data -->
<!-- ```{r, eval=FALSE} -->
<!-- ## Read raw files and bind: -->
<!-- #files = list.files(path = paste0(dir, "LUCAS2015_Soil_Spectra_EU28"), pattern = ".csv", full.names=TRUE, recursive=TRUE) -->
<!-- #temp = lapply(files, fread, sep=",") -->
<!-- #lucas.vnir = rbindlist(temp) -->
<!-- #colnames(lucas.vnir) -->
<!-- #head(lucas.vnir[, c(1:6, 4204:4205)], 5) -->
<!-- #saveRDS.gz(lucas.vnir, paste(dir, "LUCAS_spectra_2015.rds")) -->
<!-- ``` -->
<!-- VNIR soil spectroscopy raw data: -->
<!-- ```{r} -->
<!-- load(paste0(dir, "LUCAS.SOIL_corr.Rdata")) -->
<!-- lucas.vnir2009 = LUCAS.SOIL$spc -->
<!-- summary(lucas.vnir2009$`416`) -->
<!-- summary(lucas.vnir2009$`2100`) -->
<!-- lucas.vnir2015 = readRDS.gz(paste0(dir, "LUCAS_spectra_2015.rds")) -->
<!-- summary(lucas.vnir2015$`416`) -->
<!-- summary(as.numeric(lucas.vnir2015$`2100`)) -->
<!-- ``` -->
<!-- Detect negative values / convert to reflectances. -->
<!-- ```{r} -->
<!-- sel.vnir2015 = names(lucas.vnir2015)[6:ncol(lucas.vnir2015)] -->
<!-- ## 4200 -->
<!-- ## convert to percent reflectance -->
<!-- lucas.vnir2015.f = parallel::mclapply(as.data.frame(lucas.vnir2015)[,6:ncol(lucas.vnir2015)], function(j){1/exp(as.numeric(j))}, mc.cores=32) -->
<!-- lucas.vnir2015.f = as.data.frame(do.call(cbind, lucas.vnir2015.f)) -->
<!-- library(doMC) -->
<!-- cl = makeCluster(mc <- getOption("cl.cores", 32)) -->
<!-- samples0.na.gaps = parallel::parRapply(cl, lucas.vnir2015.f, FUN=function(j){ round(100*sum(is.na(j))/length(j), 3)})  -->
<!-- samples0.negative = parallel::parRapply(cl, lucas.vnir2015.f, FUN=function(j){ round(100*sum(j <= 0, na.rm = TRUE)/length(j), 3) }) -->
<!-- sum(samples0.negative>0, na.rm=TRUE) -->
<!-- samples0.extreme = parallel::parRapply(cl, lucas.vnir2015.f, FUN=function(j){ round(100*sum(j >= 1, na.rm = TRUE)/length(j), 3) }) -->
<!-- sum(samples0.extreme>0, na.rm=TRUE) -->
<!-- stopCluster(cl) -->
<!-- lucas.vnir2015.f = round(lucas.vnir2015.f*100, 1) -->
<!-- vnir2015.s = sapply(names(lucas.vnir2015)[sel.vnir2015], function(i){ strsplit(i, "_")[[1]][2] }) -->
<!-- vnir2015.n = paste0("scan_visnir.", sel.vnir2015, "_pcnt") -->
<!-- names(lucas.vnir2015.f) = vnir2015.n -->
<!-- lucas.vnir2015.f$id.layer_local_c = paste0("2015.", lucas.vnir2015$PointID) -->
<!-- lucas.vnir2015.f$id.scan_local_c = make.unique(paste(lucas.vnir2015$SampleID)) -->
<!-- rm(lucas.vnir2015); gc() -->
<!-- ``` -->
<!-- Plot and check individual curves: -->
<!-- ```{r} -->
<!-- matplot(y=as.vector(t(lucas.vnir2015.f[10250,vnir2015.n])), x=as.numeric(sel.vnir2015), -->
<!--         ylim = c(0,100), -->
<!--         type = 'l',  -->
<!--         xlab = "Wavelength",  -->
<!--         ylab = "Reflectance" -->
<!--         ) -->
<!-- ``` -->
<!-- ```{r} -->
<!-- sel.vnir2009 = names(lucas.vnir2009) -->
<!-- lucas.vnir2009.f = parallel::mclapply(as.data.frame(lucas.vnir2009), function(j){1/exp(as.numeric(j))}, mc.cores=32) -->
<!-- lucas.vnir2009.f = as.data.frame(do.call(cbind, lucas.vnir2009.f)) -->
<!-- library(doMC) -->
<!-- cl = makeCluster(mc <- getOption("cl.cores", 32)) -->
<!-- samples1.na.gaps = parallel::parRapply(cl, lucas.vnir2009.f, FUN=function(j){ round(100*sum(is.na(j))/length(j), 3)})  -->
<!-- samples1.negative = parallel::parRapply(cl, lucas.vnir2009.f, FUN=function(j){ round(100*sum(j <= 0)/length(j), 3) }) -->
<!-- sum(samples1.negative>0, na.rm=TRUE) -->
<!-- samples1.extreme = parallel::parRapply(cl, lucas.vnir2009.f, FUN=function(j){ round(100*sum(j >= 1)/length(j), 3) }) -->
<!-- sum(samples0.extreme>0, na.rm=TRUE) -->
<!-- stopCluster(cl) -->
<!-- lucas.vnir2009.f = round(lucas.vnir2009.f*100, 1) -->
<!-- vnir2009.n = paste0("scan_visnir.", sel.vnir2009, "_pcnt") -->
<!-- names(lucas.vnir2009.f) = vnir2009.n -->
<!-- lucas.vnir2009.f$id.layer_local_c = paste0("2009.", LUCAS.SOIL$POINT_ID) -->
<!-- lucas.vnir2009.f$id.scan_local_c = make.unique(paste(LUCAS.SOIL$sample.ID)) -->
<!-- rm(lucas.vnir2009); gc() -->
<!-- ``` -->
<!-- Plot and check individual curves: -->
<!-- ```{r} -->
<!-- matplot(y=as.vector(t(lucas.vnir2009.f[524,vnir2009.n])), x=as.numeric(sel.vnir2009), -->
<!--         ylim = c(0,100), -->
<!--         type = 'l',  -->
<!--         xlab = "Wavelength",  -->
<!--         ylab = "Reflectance" -->
<!--         ) -->
<!-- ``` -->
<!-- Add missing columns: -->
<!-- ```{r} -->
<!-- lucas.vnir2009.f$scan.date.begin_iso.8601_yyyy.mm.dd = as.Date("2009-06-01") -->
<!-- lucas.vnir2009.f$scan.date.end_iso.8601_yyyy.mm.dd = as.Date("2012-11-01") -->
<!-- lucas.vnir2009.f$scan.license.address_idn_url = "https://esdac.jrc.ec.europa.eu/content/lucas-2009-topsoil-data" -->
<!-- lucas.vnir2009.f$scan.doi_idf_c = "10.1371/journal.pone.0066409" -->
<!-- lucas.vnir2009.f$scan.visnir.nafreq_ossl_pct = samples1.na.gaps -->
<!-- lucas.vnir2009.f$scan.visnir.negfreq_ossl_pct = samples1.negative -->
<!-- lucas.vnir2009.f$scan.visnir.extfreq_ossl_pct = samples1.extreme -->
<!-- lucas.vnir2015.f$scan.date.begin_iso.8601_yyyy.mm.dd = as.Date("2015-03-01") -->
<!-- lucas.vnir2015.f$scan.date.end_iso.8601_yyyy.mm.dd = as.Date("2015-12-01") -->
<!-- lucas.vnir2015.f$scan.license.address_idn_url = "https://esdac.jrc.ec.europa.eu/content/lucas2015-topsoil-data" -->
<!-- lucas.vnir2015.f$scan.doi_idf_c = "10.2788/97922" -->
<!-- lucas.vnir2015.f$scan.visnir.nafreq_ossl_pct = samples0.na.gaps -->
<!-- lucas.vnir2015.f$scan.visnir.negfreq_ossl_pct = samples0.negative -->
<!-- lucas.vnir2015.f$scan.visnir.extfreq_ossl_pct = samples0.extreme -->
<!-- ``` -->
<!-- Bind the two periods into a single object: -->
<!-- ```{r} -->
<!-- lucas.vnir.f = plyr::rbind.fill(lucas.vnir2009.f, lucas.vnir2015.f) -->
<!-- #v.unique_id = uuid::UUIDgenerate(use.time=TRUE, n=nrow(lucas.vnir.f))  -->
<!-- lucas.vnir.f$id.scan_uuid_c = openssl::md5(make.unique(paste0("LUCAS.VNIR", lucas.vnir.f$id.scan_local_c))) -->
<!-- ``` -->
<!-- Resample values and remove values 350--450 nm: -->
<!-- ```{r} -->
<!-- lucas.vnir.spec = lucas.vnir.f[,grep("scan_visnir.", names(lucas.vnir.f))] -->
<!-- wav.nir = sapply(names(lucas.vnir.spec), function(i){strsplit(strsplit(i, "scan_visnir.")[[1]][2], "_pcnt")[[1]][1]}) -->
<!-- colnames(lucas.vnir.spec) = wav.nir -->
<!-- rownames(lucas.vnir.spec) = lucas.vnir.f$id.scan_uuid_c -->
<!-- ## large processing time -->
<!-- lucas.vnir = prospectr::resample(lucas.vnir.spec, wav.nir, seq(350, 2500, by=2), interpol = "spline")  -->
<!-- ## Wavelength by 2 cm-1 -->
<!-- lucas.vnir = as.data.frame(lucas.vnir) -->
<!-- visnir.n = paste0("scan_visnir.", seq(350, 2500, by=2), "_pcnt") -->
<!-- colnames(lucas.vnir) = visnir.n -->
<!-- ``` -->
<!-- The beginning of the Vis (400–500 nm) showed instrumental artifacts and was therefore removed. -->
<!-- For more details see: <https://journals.plos.org/plosone/article?id=10.1371/journal.pone.0066409>: -->
<!-- ```{r} -->
<!-- lucas.vnir = lucas.vnir[,-(1:length(seq(350, 450, by=2)))] -->
<!-- ``` -->
<!-- Final check (now without 350--450 nm): -->
<!-- ```{r} -->
<!-- matplot(y=as.vector(t(lucas.vnir[100,])), x=seq(452, 2500, by=2), -->
<!--         ylim = c(0,100), -->
<!--         type = 'l',  -->
<!--         xlab = "Wavelength",  -->
<!--         ylab = "Reflectance" -->
<!--         ) -->
<!-- ``` -->
<!-- Adding other basic columns: -->
<!-- ```{r} -->
<!-- lucas.vnir$id.scan_uuid_c = rownames(lucas.vnir.spec) -->
<!-- lucas.vnir$id.scan_local_c = plyr::join(lucas.vnir["id.scan_uuid_c"], lucas.vnir.f[,c("id.scan_local_c", "id.scan_uuid_c")])$id.scan_local_c -->
<!-- lucas.vnir$id.layer_local_c = plyr::join(lucas.vnir["id.scan_uuid_c"], lucas.vnir.f[,c("id.layer_local_c", "id.scan_uuid_c")])$id.layer_local_c -->
<!-- #summary(is.na(lucas.vnir$id.layer_local_c)) -->
<!-- lucas.vnir$id.layer_uuid_c = plyr::join(lucas.vnir["id.layer_local_c"], lucas.soil[,c("id.layer_local_c", "id.layer_uuid_c")])$id.layer_uuid_c -->
<!-- summary(is.na(lucas.vnir$id.layer_uuid_c)) -->
<!-- ## 2 NA -->
<!-- lucas.vnir$scan.visnir.nafreq_ossl_pct = plyr::join(lucas.vnir["id.scan_uuid_c"], lucas.vnir.f[,c("id.scan_uuid_c", "scan.visnir.nafreq_ossl_pct")])$scan.visnir.nafreq_ossl_pct -->
<!-- lucas.vnir$scan.visnir.negfreq_ossl_pct = plyr::join(lucas.vnir["id.scan_uuid_c"], lucas.vnir.f[,c("id.scan_uuid_c", "scan.visnir.negfreq_ossl_pct")])$scan.visnir.negfreq_ossl_pct -->
<!-- lucas.vnir$scan.visnir.extfreq_ossl_pct = plyr::join(lucas.vnir["id.scan_uuid_c"], lucas.vnir.f[,c("id.scan_uuid_c", "scan.visnir.extfreq_ossl_pct")])$scan.visnir.extfreq_ossl_pct -->
<!-- lucas.vnir$scan.date.begin_iso.8601_yyyy.mm.dd = lucas.vnir.f$scan.date.begin_iso.8601_yyyy.mm.dd -->
<!-- lucas.vnir$scan.date.end_iso.8601_yyyy.mm.dd = lucas.vnir.f$scan.date.end_iso.8601_yyyy.mm.dd -->
<!-- lucas.vnir$scan.license.address_idn_url = lucas.vnir.f$scan.license.address_idn_url -->
<!-- lucas.vnir$scan.doi_idf_c = lucas.vnir.f$scan.doi_idf_c -->
<!-- lucas.vnir$model.name_utf8_txt = "XDS Rapid Content Analyzer" -->
<!-- lucas.vnir$model.code_any_c = "XDS_Rapid_Content_Analyzer" -->
<!-- lucas.vnir$method.light.source_any_c = "" -->
<!-- lucas.vnir$method.preparation_any_c = "" -->
<!-- #lucas.vnir.f$scan.file_any_c = "" -->
<!-- lucas.vnir$scan.license.title_ascii_txt = "JRC License Agreement" -->
<!-- lucas.vnir$scan.contact.name_utf8_txt = "ESDAC - European Commission" -->
<!-- lucas.vnir$scan.contact.email_ietf_email = "ec-esdac@jrc.ec.europa.eu" -->
<!-- ``` -->
<!-- Save final table: -->
<!-- ```{r} -->
<!-- x.na = visnir.name[which(!visnir.name %in% names(lucas.vnir))] -->
<!-- if(length(x.na)>0){ for(i in x.na){ lucas.vnir[,i] <- NA } } -->
<!-- #str(lucas.vnir[,visnir.name[1:24]]) -->
<!-- visnir.rds = paste0(dir, "ossl_visnir_v1.rds") -->
<!-- if(!file.exists(visnir.rds)){ -->
<!--   saveRDS.gz(lucas.vnir[,visnir.name], visnir.rds) -->
<!-- } -->
<!-- ``` -->
<!-- ### MIR data scanned by Woodwell Climate Research -->
<!-- MIR available only for a smaller selection of samples -->
<!-- ```{r} -->
<!-- lucas.mir = vroom::vroom("/mnt/soilspec4gg/ossl/dataset/validation/LUCAS_Woodwell.csv") -->
<!-- dim(lucas.mir) -->
<!-- summary(as.factor(lucas.mir$run_date)) -->
<!-- sel.abs = names(lucas.mir)[19:ncol(lucas.mir)] -->
<!-- ## 3017 -->
<!-- str(lucas.mir$POINT_ID) -->
<!-- lucas.mir$id.layer_local_c = paste0("2009.", lucas.mir$POINT_ID) -->
<!-- str(lucas.mir$id.layer_local_c[which(!lucas.mir$id.layer_local_c %in% lucas.site$id.layer_local_c)]) -->
<!-- lucas.mir$id.scan_uuid_c = openssl::md5(make.unique(paste0("LUCAS.MIR", lucas.mir$id.layer_local_c))) -->
<!-- #summary(duplicated(lucas.mir$id.scan_uuid_c)) -->
<!-- ``` -->
<!-- Resampling the MIR spectra from the original window size to 2 cm-1 in `lucas.abs`. -->
<!-- This operation can be time-consuming: -->
<!-- ```{r} -->
<!-- lucas.abs = lucas.mir[,c("id.scan_uuid_c", sel.abs)] -->
<!-- dim(lucas.abs) -->
<!-- wav.mir = as.numeric(sel.abs) # Get wavelength only -->
<!-- summary(wav.mir) -->
<!-- # Creating a matrix with only spectral values to resample it -->
<!-- lucas.mir.spec = as.matrix(lucas.abs[,sel.abs]) -->
<!-- colnames(lucas.mir.spec) = wav.mir -->
<!-- #rownames(lucas.mir.spec) = lucas.mir$id.scan_uuid_c -->
<!-- samples.na.gaps = apply(lucas.mir.spec, 1, FUN=function(j){ round(100*sum(is.na(j))/length(j), 3)})  -->
<!-- samples.negative = apply(lucas.mir.spec, 1, FUN=function(j){ round(100*sum(j <= 0, na.rm=TRUE)/length(j), 3) }) -->
<!-- sum(samples.negative>0) -->
<!-- samples.extreme = apply(lucas.mir.spec, 1, FUN=function(j){ round(100*sum(j >= 3, na.rm=TRUE)/length(j), 3) }) -->
<!-- sum(samples.extreme>0) -->
<!-- ## resample values -->
<!-- lucas.mir = prospectr::resample(lucas.mir.spec, wav.mir, seq(600, 4000, 2))  -->
<!-- lucas.mir = round(as.data.frame(lucas.mir)*1000) -->
<!-- mir.n = paste0("scan_mir.", seq(600, 4000, 2), "_abs") -->
<!-- colnames(lucas.mir) = mir.n -->
<!-- lucas.mir$id.scan_uuid_c = lucas.abs$id.scan_uuid_c -->
<!-- ``` -->
<!-- Plotting MIR spectra to see if there are still maybe negative values in the table: -->
<!-- ```{r} -->
<!-- matplot(y=as.vector(t(lucas.mir[25,mir.n])), x=seq(600, 4000, 2), -->
<!--         ylim = c(0,3000), -->
<!--         type = 'l',  -->
<!--         xlab = "Wavelength",  -->
<!--         ylab = "Absorbance" -->
<!--         ) -->
<!-- ``` -->
<!-- Export final MIR table: -->
<!-- ```{r} -->
<!-- lucas.mir$id.layer_local_c = plyr::join(lucas.mir["id.scan_uuid_c"], lucas.vnir[c("id.scan_uuid_c","id.layer_local_c")], match="first")$id.layer_local_c -->
<!-- #summary(is.na(lucas.mir$id.scan_uuid_c)) -->
<!-- lucas.mir$id.layer_uuid_c = plyr::join(lucas.mir["id.layer_local_c"], lucas.soil[,c("id.layer_local_c", "id.layer_uuid_c")])$id.layer_uuid_c -->
<!-- summary(is.na(lucas.mir$id.layer_uuid_c)) -->
<!-- lucas.mir$model.name_utf8_txt = "Bruker Vertex 70 with HTS-XT accessory" -->
<!-- lucas.mir$model.code_any_c = "Bruker_Vertex_70.HTS.XT" -->
<!-- lucas.mir$method.light.source_any_c = "" -->
<!-- lucas.mir$method.preparation_any_c = "" -->
<!-- lucas.mir$scan.file_any_c = "" -->
<!-- lucas.mir$scan.date.begin_iso.8601_yyyy.mm.dd = "2019-04-26" -->
<!-- lucas.mir$scan.date.end_iso.8601_yyyy.mm.dd = "2019-06-13" -->
<!-- lucas.mir$scan.license.title_ascii_txt = "CC-BY" -->
<!-- lucas.mir$scan.license.address_idn_url = "https://creativecommons.org/licenses/by/4.0/" -->
<!-- lucas.mir$scan.doi_idf_c = "10.3390/s20236729" -->
<!-- lucas.mir$scan.contact.name_utf8_txt = "Jonathan Sanderman" -->
<!-- lucas.mir$scan.contact.email_ietf_email = "jsanderman@woodwellclimate.org" -->
<!-- lucas.mir$scan.mir.nafreq_ossl_pct = samples.na.gaps -->
<!-- lucas.mir$scan.mir.negfreq_ossl_pct = samples.negative -->
<!-- lucas.mir$scan.mir.extfreq_ossl_pct = samples.extreme -->
<!-- ``` -->
<!-- Save to RDS file: -->
<!-- ```{r} -->
<!-- x.na = mir.name[which(!mir.name %in% names(lucas.mir))] -->
<!-- if(length(x.na)>0){ for(i in x.na){ lucas.mir[,i] <- NA } } -->
<!-- #str(lucas.mir[,mir.name[1:24]]) -->
<!-- mir.rds = paste0(dir, "ossl_mir_v1.rds") -->
<!-- if(!file.exists(mir.rds)){ -->
<!--   saveRDS.gz(lucas.mir[,mir.name], mir.rds) -->
<!-- } -->
<!-- ``` -->
<!-- ### Quality control -->
<!-- Check if some points don't have any spectral scans: -->
<!-- ```{r} -->
<!-- mis.r = lucas.mir$id.layer_local_c %in% lucas.site$id.layer_local_c -->
<!-- summary(mis.r) -->
<!-- #str(lucas.mir$id.layer_local_c[which(!lucas.mir$id.layer_local_c %in% lucas.site$id.layer_local_c)]) -->
<!-- ``` -->
<!-- ### Distribution of points -->
<!-- We can plot an world map showing distribution of the sampling locations for the LUCAS data. -->
<!-- ```{r, lucas.pnts_sites} -->
<!-- # Get the world map -->
<!-- if(!require(rworldmap)){install.packages("rworldmap"); require(rworldmap)} -->
<!-- worldMap = getMap() -->
<!-- # Member States of the European Union -->
<!-- europeanUnion = c("Austria","Belgium","Bulgaria","Croatia","Cyprus", -->
<!--                    "Czech Rep.","Denmark","Estonia","Finland","France", -->
<!--                    "Germany","Greece","Hungary","Ireland","Italy","Latvia", -->
<!--                    "Lithuania","Luxembourg","Malta","Netherlands","Poland", -->
<!--                    "Portugal","Romania","Slovakia","Slovenia","Spain", -->
<!--                    "Sweden","United Kingdom","Icelaand") -->
<!-- # Select only the index of states member of the E.U. -->
<!-- indEU = which(worldMap$NAME%in%europeanUnion) -->
<!-- # Extract longitude and latitude border's coordinates of members states of E.U.  -->
<!-- europeCoords = lapply(indEU, function(i){ -->
<!--   df = data.frame(worldMap@polygons[[i]]@Polygons[[1]]@coords) -->
<!--   df$region = as.character(worldMap$NAME[i]) -->
<!--   colnames(df) = list("long", "lat", "region") -->
<!--   return(df) -->
<!-- }) -->
<!-- europeCoords = do.call("rbind", europeCoords) -->
<!-- lucas.map = ggplot() + geom_polygon(data = europeCoords, aes(x = long, y = lat, group = region), colour = "black", size = 0.1) + -->
<!--   coord_map(xlim = c(-13, 35),  ylim = c(32, 71)) -->
<!-- lucas.map = lucas.map + geom_point(aes(x=lucas.site$longitude_wgs84_dd, y=lucas.site$latitude_wgs84_dd), color = 'blue', shape = 18, size=.9) -->
<!-- lucas.map -->
<!-- ``` -->
<!-- Fig.  1: LUCAS locations of sites across the globe. -->
<!-- ```{r, eval=FALSE} -->
<!-- rm(lucas.vnir.f); rm(lucas.vnir.spec); rm(LUCAS.SOIL);  -->
<!-- #rm(lucas.vnir2009.f); rm(lucas.vnir2015.f) -->
<!-- gc() -->
<!-- #save.image.pigz(file=paste0(dir, "LUCAS.RData"), n.cores=32) -->
<!-- #rmarkdown::render("dataset/LUCAS/README.Rmd") -->
<!-- ``` -->
<!-- ## References -->

<div id="refs" class="references csl-bib-body hanging-indent"
line-spacing="2">

<div id="ref-orgiazzi2018lucas" class="csl-entry">

Orgiazzi, A., Ballabio, C., Panagos, P., Jones, A., & Fernández-Ugalde,
O. (2018). <span class="nocase">LUCAS Soil, the largest expandable soil
dataset for Europe: a review</span>. *European Journal of Soil Science*,
*69*(1), 140–153.
doi:[10.1111/ejss.12499](https://doi.org/10.1111/ejss.12499)

</div>

</div>
