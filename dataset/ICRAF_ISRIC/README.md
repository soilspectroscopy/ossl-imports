Dataset import: The ICRAF-ISRIC Soil and Spectral Library (ICRAF-ISRIC)
================
Tomislav Hengl (<tom.hengl@opengeohub.org>), Wanderson Mendes de Sousa
(<wanderson.mendes@zalf.de>) and Jonathan Sanderman
(<jsanderman@woodwellclimate.org>)
08 May, 2022



-   [ICRAF-ISRIC inputs](#icraf-isric-inputs)
-   [Data import](#data-import)
    -   [Soil site and laboratory data
        import:](#soil-site-and-laboratory-data-import)
        -   [Soil lab information](#soil-lab-information)
        -   [Soil site information](#soil-site-information)
    -   [Mid-infrared spectroscopy
        data](#mid-infrared-spectroscopy-data)
    -   [Visible and near-infrared spectroscopy
        data](#visible-and-near-infrared-spectroscopy-data)
    -   [Quality control](#quality-control)
    -   [Distribution of points](#distribution-of-points)
-   [References](#references)

[<img src="../../img/soilspec4gg-logo_fc.png" alt="SoilSpec4GG logo" width="250"/>](https://soilspectroscopy.org/)

[<img alt="Creative Commons License" style="border-width:0" src="https://i.creativecommons.org/l/by-sa/4.0/88x31.png" />](http://creativecommons.org/licenses/by-sa/4.0/)

This work is licensed under a [Creative Commons Attribution-ShareAlike
4.0 International
License](http://creativecommons.org/licenses/by-sa/4.0/).

## ICRAF-ISRIC inputs

Part of: <https://github.com/soilspectroscopy>  
Project: [Soil Spectroscopy for Global
Good](https://soilspectroscopy.org)  
Last update: 2022-05-08  
Dataset:
[ICRAF.ISRIC](https://soilspectroscopy.github.io/ossl-manual/soil-spectroscopy-tools-and-users.html#icraf.isric)

The ICRAF-ISRIC Soil and Spectral Library ([Garrity & Bindraban,
2004](#ref-garrity2004globally)) has samples from 58 countries worldwide
including 5 continents (Africa, Europe, South America, North America,
and Asia). The soil samples were retrieved from the Soil Information
System (ISIS), which already had the analytical data, and the spectra
were analysed in the World Agroforestry Centre’s (ICRAF). Dataset
properties and licences are explained in detail in [ISRIC’ data
portal](https://data.isric.org/geonetwork/srv/api/records/1b65024a-cd9f-11e9-a8f9-a0481ca9e724).

Input datasets:

-   `ICRAF_ISRIC_MIR_spectra.csv`: MIR soil spectral reflectances
    (&gt;3578 channels);
-   `ICRAF_ISRIC_VNIR_spectra.csv`: VNIR soil spectral reflectances
    (&gt;216 channels);
-   `ICRAF_ISRIC_reference_data.csv`: Database with site and soil
    analytes;

For the ICRAF-ISRIC dataset properties refer also to [Aitkenhead &
Black](#ref-aitkenhead2018exploring)
([2018](#ref-aitkenhead2018exploring)).

Data folder path:

``` r
dir = "/mnt/soilspec4gg/ossl/dataset/ICRAF_ISRIC/"
```

## Data import

### Soil site and laboratory data import:

``` r
icraf.df = vroom::vroom(paste(dir, "ICRAF_ISRIC_reference_data.csv", sep = ""))
```

    ## New names:
    ## * Remarks -> Remarks...41
    ## * Remarks -> Remarks...64

    ## Rows: 4,239
    ## Columns: 64
    ## Delimiter: ","
    ## chr [ 7]: Batch and labid, Country name, Plotcode, N / S, E / W, Remarks, Remarks
    ## dbl [53]: ICRAF sample codes.SAMPLENO, HORI, BTOP, BBOT, Dsed, Lat: degr, Lat: min, Lat: sec, Long: degr, Long: min, Long: sec, Sample no, pH (H2O), pH (KCl), CaCO3, ...
    ## lgl [ 4]: pH (CaCl2), CaSO4, COLE, SSA
    ## 
    ## Use `spec()` to retrieve the guessed column specification
    ## Pass a specification to the `col_types` argument to quiet this message

``` r
## dataset ISIS: https://www.isric.org/sites/default/files/isric_report_1995_10b.pdf
```

#### Soil lab information

``` r
in.name = c("pH (H2O)", "pH (KCl)", "pH (CaCl2)", "CaCO3", "Org C", "Org N", "Ca", 
            "Mg", "Na", "K", "Exch acid", "Exch Al", "CEC soil", "ECEC", "Tot S",
            "Tot Si", "Clay", "BD", "El cond", "Base sat", "pF4.2", "pF2.7")
icraf.yw = as.data.frame(icraf.df[,in.name])
out.name = c("ph.h2o_usda.4c1_index", "ph.kcl_usda.4c1_index", "ph.cacl2_usda.4c1_index", "caco3_usda.4e1_wpct", "oc_usda.calc_wpct", "n.tot_usda.4h2_wpct", "ca.ext_usda.4b1_cmolkg",
             "mg.ext_usda.4b1_cmolkg", "na.ext_usda.4b1_cmolkg", "k.ext_usda.4b1_cmolkg", "acid.tea_usda4b2_cmolkg", "al.kcl_usda.4b3_cmolkg", "cec.ext_usda.4b1_cmolkg", "ecec_usda.4b4_cmolkg", "sand.tot_usda.3a1_wpct", "silt.tot_usda.3a1_wpct", "clay.tot_usda.3a1_wpct", "bd.od_usda.3b2_gcm3", "ec.w_usda.4f1_dsm", "bsat_usda.4b4_wpct", "wr.1500kbar_usda.3c2_wpct", "wr.33kbar_usda.3c1_wpct")
## compare values
#summary(icraf.yw$`pH (H2O)`)
#summary(icraf.yw$`Org C`)
#summary(icraf.yw$`Org N`)
#summary(icraf.yw$`Ca`)
#summary(icraf.yw$`BD`)
#summary(icraf.yw$`Clay`)
#summary(icraf.yw$`pF4.2`)
fun.lst = as.list(rep("x*1", length(in.name)))
fun.lst[[which(in.name=="BD")]] = "ifelse(x<0.05, NA, x*1)"
## save translation rules:
#View(data.frame(in.name, out.name, unlist(fun.lst)))
write.csv(data.frame(in.name, out.name, unlist(fun.lst)), "./icraf_soilab_transvalues.csv")
icraf.soil = transvalues(icraf.yw, out.name, in.name, fun.lst)
icraf.soil$id.layer_local_c = icraf.df$`Batch and labid`
#summary(duplicated(icraf.soil$id.layer_local_c))
```

Exporting the table:

``` r
icraf.soil$id.layer_uuid_c = openssl::md5(make.unique(icraf.soil$id.layer_local_c))
icraf.soil$sample.doi_idf_c = "10.34725/DVN/MFHA9C"
icraf.soil$sample.contact.name_utf8_txt = "Keith Shepherd"
icraf.soil$sample.contact.email_ietf_email = "afsis.info@africasoils.net"
x.na = soilab.name[which(!soilab.name %in% names(icraf.soil))]
if(length(x.na)>0){ for(i in x.na){ icraf.soil[,i] <- NA } }
soilab.rds = paste0(dir, "ossl_soillab_v1.rds")
if(!file.exists(soilab.rds)){
  saveRDS.gz(icraf.soil[,soilab.name], soilab.rds)
}
```

#### Soil site information

``` r
icraf.site = as.data.frame(icraf.df[,1:17])
icraf.site$`Long: sec` = ifelse(is.na(icraf.site$`Long: sec`), 0, icraf.site$`Long: sec`)
icraf.site$`Lat: sec` = ifelse(is.na(icraf.site$`Lat: sec`), 0, icraf.site$`Lat: sec`)
icraf.site$lat = ifelse(icraf.site$`N / S`=="South", paste0("-", icraf.site$`Lat: degr`, " ", icraf.site$`Lat: min`, " ", icraf.site$`Lat: sec`), paste0(icraf.site$`Lat: degr`, " ", icraf.site$`Lat: min`, " ", icraf.site$`Lat: sec`))
icraf.site$lon = ifelse(icraf.site$`E / W`=="West", paste0("-", icraf.site$`Long: degr`, " ", icraf.site$`Long: min`, " ", icraf.site$`Long: sec`), paste0(icraf.site$`Long: degr`, " ", icraf.site$`Long: min`, " ", icraf.site$`Long: sec`))
icraf.site$layer.sequence_usda_uint16 = icraf.site$HORI
icraf.site$layer.upper.depth_usda_cm = icraf.site$BTOP
icraf.site$layer.lower.depth_usda_cm = icraf.site$BBOT
## soil taxonomy:
isis.xy <- read.csv("/mnt/diskstation/data/Soil_points/INT/ISRIC_ISIS/Sites.csv", stringsAsFactors = FALSE)
#str(isis.xy)
isis.xy$SiteId = isis.xy$Id
isis.xy$Plotcode = paste(isis.xy$CountryISO, isis.xy$Id)
isis.des <- read.csv("/mnt/diskstation/data/Soil_points/INT/ISRIC_ISIS/SitedescriptionResults.csv", stringsAsFactors = FALSE)
id0.lst = c(236,235,224); nm0.lst = c("longitude_decimal_degrees", "latitude_decimal_degrees", "site_obsdate")
isis.site.l = plyr::join_all(lapply(1:length(id0.lst), function(i){plyr::rename(subset(isis.des, ValueId==id0.lst[i])[,c("SampleId","Value")], replace=c("Value"=paste(nm0.lst[i])))}), type = "full")
```

    ## Joining by: SampleId
    ## Joining by: SampleId

``` r
isis.tax.smp = read.csv("/mnt/diskstation/data/Soil_points/INT/ISRIC_ISIS/ClassificationSamples.csv", stringsAsFactors = FALSE)
isis.tax.smp$SampleId = isis.tax.smp$Id
isis.tax.smp$Plotcode = plyr::join(isis.tax.smp, isis.xy, by="SiteId")$Plotcode
isis.xy$SampleId = plyr::join(isis.xy, isis.tax.smp, by="SiteId", match="first")$SampleId
isis.xy = join(isis.xy, isis.site.l)
```

    ## Joining by: SampleId

``` r
isis.tax = read.csv("/mnt/diskstation/data/Soil_points/INT/ISRIC_ISIS/ClassificationResults.csv", stringsAsFactors = FALSE)
id0.lst = c(195,196,198,199,200); nm0.lst = c("USGG_75", "USGG_99", "USSG_75", "USSG_92", "USSG_99")
tax.kst = plyr::join_all(lapply(1:length(id0.lst), function(i){plyr::rename(subset(isis.tax, ValueId==id0.lst[i])[,c("SampleId","Value")], replace=c("Value"=paste(nm0.lst[i])))}), type = "full")
```

    ## Joining by: SampleId
    ## Joining by: SampleId
    ## Joining by: SampleId
    ## Joining by: SampleId

``` r
tax.kst$Plotcode = plyr::join(tax.kst, isis.tax.smp[,c("SampleId", "Plotcode")])$Plotcode
```

    ## Joining by: SampleId

``` r
tax.kst$pedon.taxa_usda_c = paste0(ifelse(is.na(tax.kst$USSG_99), ifelse(is.na(tax.kst$USSG_92), tax.kst$USSG_75, tax.kst$USSG_92), tax.kst$USSG_99), " ", ifelse(is.na(tax.kst$USGG_99), tax.kst$USGG_75, tax.kst$USGG_99))
#tax.kst[1:4,]
icraf.site$pedon.taxa_usda_c = plyr::join(icraf.site, tax.kst[,c("Plotcode", "pedon.taxa_usda_c")])$pedon.taxa_usda_c
```

    ## Joining by: Plotcode

``` r
icraf.site$longitude_wgs84_dd = plyr::join(icraf.site, isis.xy)$longitude_decimal_degrees
```

    ## Joining by: Plotcode

``` r
icraf.site$latitude_wgs84_dd = plyr::join(icraf.site, isis.xy)$latitude_decimal_degrees
```

    ## Joining by: Plotcode

``` r
icraf.site$longitude_wgs84_dd = as.numeric(ifelse(is.na(icraf.site$longitude_wgs84_dd), measurements::conv_unit(icraf.site$lon, from = 'deg_min_sec', to = 'dec_deg'), icraf.site$longitude_wgs84_dd))
```

    ## Warning in split(as.numeric(unlist(strsplit(x_na_free, " "))) * c(3600, : NAs introduced by coercion

``` r
icraf.site$latitude_wgs84_dd = as.numeric(ifelse(is.na(icraf.site$latitude_wgs84_dd), measurements::conv_unit(icraf.site$lat, from = 'deg_min_sec', to = 'dec_deg'), icraf.site$latitude_wgs84_dd))
```

    ## Warning in split(as.numeric(unlist(strsplit(x_na_free, " "))) * c(3600, : NAs introduced by coercion

``` r
#plot(icraf.site[,c("longitude_wgs84_dd","latitude_wgs84_dd")])
icraf.site$id.layer_local_c = icraf.df$`Batch and labid`
icraf.site$id.location_olc_c = olctools::encode_olc(icraf.site$latitude_wgs84_dd, icraf.site$longitude_wgs84_dd, 10)
```

Exporting the table:

``` r
icraf.site$id.layer_uuid_c = openssl::md5(make.unique(icraf.site$id.layer_local_c))
icraf.site$observation.ogc.schema.title_ogc_txt = 'Open Soil Spectroscopy Library'
icraf.site$observation.ogc.schema_idn_url = 'https://soilspectroscopy.github.io'
icraf.site$location.method_any_c = "GPS"
icraf.site$location.error_any_m = 30
icraf.site$dataset.license.title_ascii_txt = "CC-BY"
icraf.site$dataset.license.address_idn_url = "https://creativecommons.org/licenses/by/4.0/"
icraf.site$dataset.title_utf8_txt = "ICRAF-ISRIC Soil MIR Spectral Library"
icraf.site$surveyor.address_utf8_txt = "ICRAF, PO Box 30677, Nairobi, 00100, Kenya"
icraf.site$dataset.code_ascii_c = "ICRAF.ISRIC"
icraf.site$dataset.address_idn_url = "https://www.isric.org/explore/ISRIC-collections"
icraf.site$dataset.owner_utf8_txt = "World Agroforestry Centre (ICRAF) / ISRIC - World Soil Information"
icraf.site$surveyor.title_utf8_txt = "Stephan Mantel"
icraf.site$surveyor.contact_ietf_email = "stephan.mantel@wur.nl"
icraf.site$dataset.contact.name_utf8_txt = "Keith Shepherd"
icraf.site$dataset.contact_ietf_email = "afsis.info@africasoils.net"
x.na = site.name[which(!site.name %in% names(icraf.site))]
if(length(x.na)>0){ for(i in x.na){ icraf.site[,i] <- NA } }
soilsite.rds = paste0(dir, "ossl_soilsite_v1.rds")
if(!file.exists(soilsite.rds)){
  saveRDS.gz(icraf.site[,site.name], soilsite.rds)
}
```

### Mid-infrared spectroscopy data

Mid-infrared (MIR) soil spectroscopy raw data:

``` r
if(!exists("icraf.mir")){
  icraf.mir = vroom::vroom(paste(dir, "ICRAF_ISRIC_MIR_spectra.csv", sep = ""))
}
```

Some duplicates (average values?).

``` r
# MIR data
sum(duplicated(icraf.mir$SSN)) # 155 obs.
```

    ## [1] 155

``` r
#icraf.mir <- icraf.mir %>%
#  group_by(SSN) %>%
#  summarise_all(mean)
#sum(duplicated(icraf.mir$SSN))
```

Add the [Universal Unique
Identifier](https://cran.r-project.org/web/packages/uuid/) (UUI):

``` r
icraf.mir$id.scan_uuid_c = openssl::md5(make.unique(paste0("ICRAF.ISRIC", icraf.mir$SSN)))
```

Resampling the MIR spectra from the original window size to 2 cm-1 in
`icraf.abs`. This operation can be time-consuming:

``` r
sel.abs = names(icraf.mir)[grep("^m", names(icraf.mir))]
## 3578
icraf.abs = icraf.mir[,c("id.scan_uuid_c", "SSN", sel.abs)]
dim(icraf.abs)
```

    ## [1] 4308 3580

List any possible problems in spectral scans:

``` r
wav.mir = as.numeric(gsub("m", "", sel.abs)) # Get wavelength only
# Creating a matrix with only spectral values to resample it
icraf.mir.spec = as.matrix(icraf.mir[,sel.abs])
colnames(icraf.mir.spec) = wav.mir
rownames(icraf.mir.spec) = icraf.mir$id.scan_uuid_c
samples.na.gaps = apply(icraf.mir.spec, 1, FUN=function(j){ round(100*sum(is.na(j))/length(j), 3)}) 
samples.negative = apply(icraf.mir.spec, 1, FUN=function(j){ round(100*sum(j <= 0, na.rm=TRUE)/length(j), 3) })
sum(samples.negative>0)
```

    ## [1] 0

``` r
samples.extreme = apply(icraf.mir.spec, 1, FUN=function(j){ round(100*sum(j >= 3, na.rm=TRUE)/length(j), 3) })
sum(samples.extreme>0)
```

    ## [1] 2

Resample values to standard wavelengths:

``` r
icraf.mir.f = prospectr::resample(icraf.mir.spec, wav.mir, seq(600, 4000, 2), interpol = "spline") 
## Wavelength by 2 cm-1
icraf.mir.f = round(as.data.frame(icraf.mir.f)*1000)
mir.n = paste0("scan_mir.", seq(600, 4000, 2), "_abs")
colnames(icraf.mir.f) = mir.n
dim(icraf.mir.f)
```

    ## [1] 4308 1701

``` r
summary(icraf.mir.f$scan_mir.602_abs)
```

    ##    Min. 1st Qu.  Median    Mean 3rd Qu.    Max. 
    ##     683    1543    1663    1646    1764    2200

``` r
icraf.mir.f$id.scan_uuid_c = rownames(icraf.mir.spec)
```

Plotting MIR spectra to see if it is still negative values in the table:

``` r
#str(names(icraf.mir.f))
matplot(y=as.vector(t(icraf.mir.f[250,mir.n])), x=seq(600, 4000, 2),
        ylim = c(0,3000),
        type = 'l', 
        xlab = "Wavelength", 
        ylab = "Absorbance"
        )
```

![](README_files/figure-gfm/unnamed-chunk-27-1.png)<!-- -->

Export final MIR table:

``` r
icraf.mir.f$id.layer_local_c = plyr::join(icraf.mir.f["id.scan_uuid_c"], icraf.abs[c("id.scan_uuid_c","SSN")])$SSN
```

    ## Joining by: id.scan_uuid_c

``` r
icraf.mir.f$id.layer_uuid_c = plyr::join(icraf.mir.f["id.layer_local_c"], icraf.soil[c("id.layer_local_c","id.layer_uuid_c")], match="first")$id.layer_uuid_c
```

    ## Joining by: id.layer_local_c

``` r
summary(is.na(icraf.mir.f$id.layer_uuid_c))
```

    ##    Mode   FALSE 
    ## logical    4308

``` r
icraf.mir.f$model.name_utf8_txt = "Bruker Vertex 70 with HTS-XT accessory"
icraf.mir.f$model.code_any_c = "Bruker_Vertex_70.HTS.XT"
icraf.mir.f$method.light.source_any_c = ""
icraf.mir.f$method.preparation_any_c = ""
icraf.mir.f$scan.file_any_c = ""
icraf.mir.f$scan.date.begin_iso.8601_yyyy.mm.dd = as.Date("2004-02-01")
icraf.mir.f$scan.date.end_iso.8601_yyyy.mm.dd = as.Date("2004-11-01")
icraf.mir.f$scan.license.title_ascii_txt = "CC-BY"
icraf.mir.f$scan.license.address_idn_url = "https://creativecommons.org/licenses/by/4.0/"
icraf.mir.f$scan.doi_idf_c = "10.34725/DVN/MFHA9C"
icraf.mir.f$scan.contact.name_utf8_txt = "Keith Shepherd"
icraf.mir.f$scan.contact.email_ietf_email = "afsis.info@africasoils.net"
icraf.mir.f$scan.mir.nafreq_ossl_pct = samples.na.gaps
icraf.mir.f$scan.mir.negfreq_ossl_pct = samples.negative
icraf.mir.f$scan.mir.extfreq_ossl_pct = samples.extreme
```

Save to RDS file:

``` r
x.na = mir.name[which(!mir.name %in% names(icraf.mir.f))]
if(length(x.na)>0){ for(i in x.na){ icraf.mir.f[,i] <- NA } }
#str(icraf.mir.f[,mir.name[1:24]])
mir.rds = paste0(dir, "ossl_mir_v1.rds")
if(!file.exists(mir.rds)){
  saveRDS.gz(icraf.mir.f[,mir.name], mir.rds)
}
#rm(icraf.mir.spec); rm(icraf.mir); rm(icraf.abs)
#gc()
```

### Visible and near-infrared spectroscopy data

Visible and near-infrared (VNIR) soil spectroscopy raw data:

``` r
icraf.vnir = vroom::vroom(paste(dir, "ICRAF_ISRIC_VNIR_spectra.csv", sep = ""))
```

    ## Rows: 4,439
    ## Columns: 217
    ## Delimiter: ","
    ## chr [  1]: Batch.Labid
    ## dbl [216]: W350, W360, W370, W380, W390, W400, W410, W420, W430, W440, W450, W460, W470, W480, W490, W500, W510, W520, W530, W540, W550, W560, W570, W580, W590, W600, W...
    ## 
    ## Use `spec()` to retrieve the guessed column specification
    ## Pass a specification to the `col_types` argument to quiet this message

``` r
icraf.vnir$id.layer_local_c = icraf.vnir$Batch.Labid
#summary(icraf.vnir$W380)
#str(which(!icraf.vnir$id.layer_local_c %in% icraf.soil$id.layer_local_c))
#283 not matching!
```

Detect negative values and similar:

``` r
sel.vnir = grep("W", names(icraf.vnir))
## 216
samples0.na.gaps = apply(icraf.vnir[,sel.vnir], 1, FUN=function(j){ round(100*sum(is.na(j))/length(j), 3)}) 
samples0.negative = apply(icraf.vnir[,sel.vnir], 1, FUN=function(j){ round(100*sum(j <= 0, na.rm = TRUE)/length(j), 3) })
sum(samples0.negative>0, na.rm=TRUE)
```

    ## [1] 1

``` r
samples0.extreme = apply(icraf.vnir[,sel.vnir], 1, FUN=function(j){ round(100*sum(j >= 1, na.rm = TRUE)/length(j), 3) })
sum(samples0.extreme>0, na.rm=TRUE)
```

    ## [1] 0

Resample to standard wavelengths:

``` r
icraf.vnir.spec = icraf.vnir[,sel.vnir]
vnir.s = sapply(names(icraf.vnir)[sel.vnir], function(i){ strsplit(i, "W")[[1]][2] })
vnir.n = paste0("scan_visnir.", vnir.s, "_pcnt")
colnames(icraf.vnir.spec) = vnir.s
## large processing time
icraf.vnir.f = prospectr::resample(icraf.vnir.spec, vnir.s, seq(350, 2500, by=2), interpol = "spline")
## Wavelength by 2 cm-1
icraf.vnir.f = round(as.data.frame(icraf.vnir.f)*100, 1)
visnir.n = paste0("scan_visnir.", seq(350, 2500, by=2), "_pcnt")
colnames(icraf.vnir.f) = visnir.n
#summary(icraf.vnir.f$scan_visnir.396_pcnt)
```

Plot and check individual curves:

``` r
matplot(y=as.vector(t(icraf.vnir.f[120,vnir.n])), x=vnir.s,
        ylim = c(0,60),
        type = 'l', 
        xlab = "Wavelength", 
        ylab = "Reflectance"
        )
```

![](README_files/figure-gfm/unnamed-chunk-33-1.png)<!-- -->

Adding basic columns:

``` r
icraf.vnir.f$id.layer_local_c = icraf.vnir$id.layer_local_c
icraf.vnir.f$id.scan_uuid_c = openssl::md5(make.unique(paste0("ICRAF.ISRIC", icraf.vnir.f$id.layer_local_c)))
summary(is.na(icraf.vnir.f$id.scan_uuid_c))
```

    ##    Mode   FALSE 
    ## logical    4439

``` r
icraf.vnir.f$id.layer_uuid_c = plyr::join(icraf.vnir.f["id.layer_local_c"], icraf.soil[c("id.layer_local_c","id.layer_uuid_c")], match="first")$id.layer_uuid_c
```

    ## Joining by: id.layer_local_c

``` r
summary(is.na(icraf.vnir.f$id.layer_uuid_c))
```

    ##    Mode   FALSE    TRUE 
    ## logical    4156     283

``` r
## 284 missing
icraf.vnir.f$model.name_utf8_txt = "ASD FieldSpec Pro FR"
icraf.vnir.f$model.code_any_c = "ASD_FieldSpec_FR"
icraf.vnir.f$method.light.source_any_c = ""
icraf.vnir.f$method.preparation_any_c = ""
#icraf.vnir.f$scan.file_any_c = ""
icraf.vnir.f$scan.date.begin_iso.8601_yyyy.mm.dd = as.Date("2004-02-01")
icraf.vnir.f$scan.date.end_iso.8601_yyyy.mm.dd = as.Date("2004-11-01")
icraf.vnir.f$scan.license.title_ascii_txt = "CC-BY"
icraf.vnir.f$scan.license.address_idn_url = "https://creativecommons.org/licenses/by/4.0/"
icraf.vnir.f$scan.doi_idf_c = "10.34725/DVN/MFHA9C"
icraf.vnir.f$scan.contact.name_utf8_txt = "Keith Shepherd"
icraf.vnir.f$scan.contact.email_ietf_email = "afsis.info@africasoils.net"
icraf.vnir.f$scan.visnir.nafreq_ossl_pct = samples0.na.gaps
icraf.vnir.f$scan.visnir.negfreq_ossl_pct = samples0.negative
icraf.vnir.f$scan.visnir.extfreq_ossl_pct = samples0.extreme
```

Save final table:

``` r
x.na = visnir.name[which(!visnir.name %in% names(icraf.vnir.f))]
if(length(x.na)>0){ for(i in x.na){ icraf.vnir.f[,i] <- NA } }
#str(icraf.vnir.f[,visnir.name[1:24]])
visnir.rds = paste0(dir, "ossl_visnir_v1.rds")
#icraf.vnir.f = icraf.vnir.f[!is.na(icraf.vnir.f$id.layer_local_c),]
if(!file.exists(visnir.rds)){
  saveRDS.gz(icraf.vnir.f[,visnir.name], visnir.rds)
}
```

### Quality control

Check if some points don’t have any spectral scans:

``` r
mis.r = icraf.mir.f$id.layer_uuid_c %in% icraf.site$id.layer_uuid_c
summary(mis.r)
```

    ##    Mode    TRUE 
    ## logical    4308

``` r
## All OK
summary(is.na(icraf.vnir.f$id.scan_uuid_c))
```

    ##    Mode   FALSE 
    ## logical    4439

``` r
summary(is.na(icraf.mir.f$id.scan_uuid_c))
```

    ##    Mode   FALSE 
    ## logical    4308

### Distribution of points

We can plot an world map showing distribution of the sampling locations
for the ICRAF-ISRIC data.

``` r
icraf.map = NULL
mapWorld = borders('world', colour = 'gray50', fill = 'gray50')
icraf.map = ggplot() + mapWorld
icraf.map = icraf.map + geom_point(aes(x=icraf.site$longitude_wgs84_dd, y=icraf.site$latitude_wgs84_dd), color = 'blue', shape = 18, size=.9)
icraf.map
```

    ## Warning: Removed 453 rows containing missing values (geom_point).

![](README_files/figure-gfm/icraf.pnts_sites-1.png)<!-- -->

Fig. 1: ICRAF-ISRIC locations of sites across the globe.

``` r
#save.image.pigz(file=paste0(dir, "ICRAF.RData"), n.cores=32)
#rmarkdown::render("dataset/ICRAF_ISRIC/README.Rmd")
```

## References

<div id="refs" class="references csl-bib-body hanging-indent"
line-spacing="2">

<div id="ref-aitkenhead2018exploring" class="csl-entry">

Aitkenhead, M. J., & Black, H. I. (2018). <span class="nocase">Exploring
the impact of different input data types on soil variable estimation
using the ICRAF-ISRIC global soil spectral database</span>. *Applied
Spectroscopy*, *72*(2), 188–198.
doi:[10.1177/0003702817739013](https://doi.org/10.1177/0003702817739013)

</div>

<div id="ref-garrity2004globally" class="csl-entry">

Garrity, D., & Bindraban, P. (2004). *A globally distributed soil
spectral library visible near infrared diffuse reflectance spectra*.
Nairobi, Kenya: ICRAF (World Agroforestry Centre) / ISRIC (World Soil
Information) Spectral Library. Retrieved from
<https://doi.org/10.34725/DVN/MFHA9C>

</div>

</div>
