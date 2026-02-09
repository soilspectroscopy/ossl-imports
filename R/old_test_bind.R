## Bind all point data
library(rgdal)
library(plyr)
library(terra)
source("R-code/functions/SSL_functions.R")
ossl.def = list(site.name, soilab.name, mir.name, visnir.name)
names(ossl.def) = c("site.name", "soilab.name", "mir.name", "visnir.name")
save(ossl.def, file="~/Documents/git/ossl/data/ossl.def.rda", compress="xz")

## Soil wet-chemistry ----
soil.lst = list.files("/mnt/soilspec4gg/ossl/dataset", "ossl_soillab_v1.rds", full.names = TRUE, recursive = TRUE)
soil.df = plyr::rbind.fill(lapply(soil.lst, readRDS.gz))
## duplicate columns
del.col = names(soil.df)[grep(glob2rx("*.1$"), names(soil.df))]
# "clay.tot_usda.3a1_wpct.1"
#View(soil.df[,c("id.layer_local_c", "sample.doi_idf_c", "clay.tot_usda.3a1_wpct", "clay.tot_usda.3a1_wpct.1")])
if(length(del.col)>0){ for(i in 1:length(del.col)){ soil.df[,del.col[i]] <- NULL } }
## date formatting problems - better remove
## Clean up typos and physically impossible values:
for(j in c("silt.tot_usda.3a1_wpct", "sand.tot_usda.3a1_wpct", "clay.tot_usda.3a1_wpct", "wpg2_usda.3a2_wpct", "wr.1500kbar_usda.3c2_wpct", "wr.33kbar_usda.3c1_wpct")){
  soil.df[,j] = ifelse(soil.df[,j]>100|soil.df[,j]<0, NA, soil.df[,j])
}
for(j in c("ph.h2o_usda.4c1_index","ph.cacl2_usda.4c1_index")){
  soil.df[,j] = ifelse(soil.df[,j]>12|soil.df[,j]<2, NA, soil.df[,j])
}
for(j in c("bd.od_usda.3b4_gcm3","bd.clod_usda.3b1_gcm3")){
  soil.df[,j] = ifelse(soil.df[,j]>2.6|soil.df[,j]<0.02, NA, soil.df[,j])
}
for(j in c("oc_usda.calc_wpct")){
  soil.df[,j] = ifelse(soil.df[,j]>80|soil.df[,j]<0, NA, soil.df[,j])
}
#hist(soil.df$n.tot_usda.4h2_wpct)
for(j in c("n.tot_usda.4h2_wpct")){
  soil.df[,j] = ifelse(soil.df[,j]>5|soil.df[,j]<0, NA, soil.df[,j])
}
#hist(soil.df$ec.w_usda.4f1_dsm)
## usual range 3 to 30 dS/m
## https://ucanr.edu/sites/Salinity/Salinity_Management/Salinity_Basics/Salinity_measurement_and_unit_conversions/
for(j in c("ec.w_usda.4f1_dsm")){
  soil.df[,j] = ifelse(soil.df[,j]>50|soil.df[,j]<0, NA, soil.df[,j])
}
summary(is.na(soil.df$id.layer_uuid_c))
summary(duplicated(soil.df$id.layer_uuid_c))
## OK all unique!
soil.df = dplyr::distinct(soil.df)
dim(soil.df)
# 118145     59

## Sampling locations ----
site.lst = list.files("/mnt/soilspec4gg/ossl/dataset", "ossl_soilsite_v1.rds", full.names = TRUE, recursive = TRUE)
site.lst.df = lapply(site.lst, readRDS.gz)
site.lst.df = lapply(site.lst.df, function(i){ i$observation.date.begin_iso.8601_yyyy.mm.dd <- paste(i$observation.date.begin_iso.8601_yyyy.mm.dd);
i$observation.date.end_iso.8601_yyyy.mm.dd <- paste(i$observation.date.end_iso.8601_yyyy.mm.dd); return(i)})
site.df = plyr::rbind.fill(site.lst.df)
summary(as.factor(site.df$dataset.code_ascii_c))
#AFSIS1.SSL  AFSIS2.SSL     CAF.SSL ICRAF.ISRIC    KSSL.SSL   LUCAS.SSL    NEON.SSL
#      2131         820        1852        4239      117218       43927         304
#head(site.df[site.df$dataset.code_ascii_c=="KSSL.SSL",1:10])
#head(site.df[site.df$dataset.code_ascii_c=="AFSIS2.SSL",1:10])
## remove total duplicates
site.df = dplyr::distinct(site.df)
dim(site.df)
# 122304     38
summary(is.na(site.df$id.location_olc_c))
## 38,977 missing locations - AfSIS-I scans
#head(site.df[which(is.na(site.df$id.location_olc_c))[1:10],])
site_yrs = site.df[!is.na(site.df$observation.date.begin_iso.8601_yyyy.mm.dd),c("observation.date.begin_iso.8601_yyyy.mm.dd", "dataset.code_ascii_c")]
site_yrs$year = as.numeric(substr(x=site_yrs$observation.date.begin_iso.8601_yyyy.mm.dd, 1, 4))
site_yrs$year = ifelse(site_yrs$year <1960, NA, ifelse(site_yrs$year>2024, NA, site_yrs$year))
library(ggplot2)
ggplot(site_yrs, aes(x=dataset.code_ascii_c, y=year)) + geom_boxplot() + theme(axis.text.x = element_text(angle = 90, hjust = 1))

#del2.col = names(site.df)[grep(glob2rx("*.1$"), names(site.df))]
#summary(site.df$location.error_any_m)
## If location accuracy is missing, we assume that location accuracy is GPS
#site.df[which(is.na(site.df$location.error_any_m))[1:2],1:10]
site.df$location.error_any_m = ifelse(is.na(site.df$location.error_any_m) & !is.na(site.df$longitude_wgs84_dd), 30, site.df$location.error_any_m)
#hist(site.df$location.error_any_m, breaks=35)
site.df$location.method_any_c = ifelse(is.na(site.df$location.method_any_c) & !is.na(site.df$longitude_wgs84_dd), "GPS", site.df$location.method_any_c)
summary(as.factor(site.df$dataset.code_ascii_c))
#AFSIS1.SSL  AFSIS2.SSL     CAF.SSL ICRAF.ISRIC    KSSL.SSL   LUCAS.SSL    NEON.SSL
#      2131         820        1852        4239       69031       43927         304
summary(is.na(site.df$id.layer_uuid_c))
## some are missing ID
## 4808
site.df$id.layer_local_c = plyr::join(site.df["id.layer_uuid_c"], soil.df[,c("id.layer_local_c","id.layer_uuid_c")], match="first")$id.layer_local_c
## sampling locations
site.xy = site.df[!duplicated(site.df$id.location_olc_c),]
site.xy = site.xy[!is.na(site.xy$longitude_wgs84_dd),]
coordinates(site.xy) = ~ longitude_wgs84_dd + latitude_wgs84_dd
proj4string(site.xy) = "EPSG:4326"
#site.xy$observation.date.begin_iso.8601_yyyy.mm.dd = paste(site.xy$observation.date.begin_iso.8601_yyyy.mm.dd)
#site.xy$observation.date.end_iso.8601_yyyy.mm.dd = paste(site.xy$observation.date.end_iso.8601_yyyy.mm.dd)
unlink("out/ossl_locations.gpkg")
writeOGR(site.xy[c("id.location_olc_c","dataset.code_ascii_c")], "out/ossl_locations.gpkg", "", "GPKG")

## Bind all VisNIR ----
visnir.lst = list.files("/mnt/soilspec4gg/ossl/dataset", "ossl_visnir_v1.rds", full.names = TRUE, recursive = TRUE)
visnir.df = plyr::rbind.fill(lapply(visnir.lst, readRDS.gz))
dim(visnir.df)
## 135294   1091
summary(is.na(visnir.df$id.scan_uuid_c))
## OK!
summary(duplicated(visnir.df$id.scan_uuid_c))
## OK!
summary(is.na(visnir.df$id.layer_local_c))
## 34,423
summary(as.factor(visnir.df$model.code_any_c))
## ASD_FieldSpec_FR        ASD_Labspec_2500_MA XDS_Rapid_Content_Analyzer
##    4439                      68259                      62596
visnir.pnts = site.df[site.df$id.layer_uuid_c %in% visnir.df$id.layer_uuid_c, c("longitude_wgs84_dd", "latitude_wgs84_dd", "id.location_olc_c")]
visnir.pnts = visnir.pnts[!is.na(visnir.pnts$longitude_wgs84_dd),]
visnir.pnts = SpatialPointsDataFrame(visnir.pnts[,1:2], data = visnir.pnts["id.location_olc_c"], proj4string = CRS("EPSG:4326"))
## World map ----
if(!file.exists("img/visnir.pnts_sites.png")){
  library(sf)
  tot_pnts_sf <- st_as_sf(visnir.pnts[1])
  plot_gh(tot_pnts_sf, out.pdf="img/visnir.pnts_sites.pdf", fill.col="cyan1")
  system("pdftoppm img/visnir.pnts_sites.pdf img/visnir.pnts_sites -png -f 1 -singlefile")
  system("convert -crop 1280x575+36+114 img/visnir.pnts_sites.png img/visnir.pnts_sites.png")
}

## Bind all MIR ----
mir.lst = list.files("/mnt/soilspec4gg/ossl/dataset", "ossl_mir_v1.rds", full.names = TRUE, recursive = TRUE)
## 6
mir.df = plyr::rbind.fill(lapply(mir.lst, readRDS.gz))
dim(mir.df)
## 95690  1720
summary(is.na(mir.df$id.scan_uuid_c))
## OK!
summary(duplicated(mir.df$id.scan_uuid_c))
## OK!
summary(is.na(mir.df$id.layer_local_c))
## 6685 missing local layers ID
summary(is.na(mir.df$id.layer_uuid_c))
## 22,858 missing uuid
#head(mir.df[which(is.na(mir.df$id.layer_uuid_c))[1:20],1:20])
summary(as.factor(mir.df$model.code_any_c))
## Bruker_Tensor_27.HTS.XT Bruker_Vertex_70.HTS.XT
##  18250                   77013
mir.pnts = site.df[site.df$id.layer_uuid_c %in% mir.df$id.layer_uuid_c, c("longitude_wgs84_dd", "latitude_wgs84_dd", "id.location_olc_c")]
mir.pnts = mir.pnts[!is.na(mir.pnts$longitude_wgs84_dd),]
mir.pnts = SpatialPointsDataFrame(mir.pnts[,1:2], data = mir.pnts["id.location_olc_c"], proj4string = CRS("EPSG:4326"))
## World map
if(!file.exists("img/mir.pnts_sites.png")){
  library(sf)
  tot_pnts_sf <- st_as_sf(mir.pnts[1])
  plot_gh(tot_pnts_sf, out.pdf="img/mir.pnts_sites.pdf", fill.col="yellow")
  system("pdftoppm img/mir.pnts_sites.pdf img/mir.pnts_sites -png -f 1 -singlefile")
  system("convert -crop 1280x575+36+114 img/mir.pnts_sites.png img/mir.pnts_sites.png")
}

## Save final images ----
## Rule 1: save only visnir/mir/soil data that match i.e. no orphaned records
id.vnir = intersect(soil.df$id.layer_uuid_c, visnir.df$id.layer_uuid_c)
id.mir = intersect(soil.df$id.layer_uuid_c, mir.df$id.layer_uuid_c)
id.s = intersect(soil.df$id.layer_uuid_c, site.df$id.layer_uuid_c)
length(id.s)
# 115644
dim(mir.df[mir.df$id.layer_uuid_c %in% id.mir,])
# 66316  1720
dim(visnir.df[visnir.df$id.layer_uuid_c %in% id.vnir,])
# 100586   1095
## Rule 2: fill in important missing fields such as location accuracy / attribution
## Rule 3: check that the data can be bind together to produce a regression matrix
## Rule 4: fix all wrong emails etc
soil.df$sample.contact.email_ietf_email = ifelse(soil.df$sample.contact.email_ietf_email=="esdac@jrc.ec.europa.eu", "ec-esdac@jrc.ec.europa.eu", soil.df$sample.contact.email_ietf_email)
site.df$surveyor.contact_ietf_email = ifelse(site.df$surveyor.contact_ietf_email=="esdac@jrc.ec.europa.eu", "ec-esdac@jrc.ec.europa.eu", site.df$surveyor.contact_ietf_email)
site.df$dataset.contact_ietf_email = ifelse(site.df$dataset.contact_ietf_email=="esdac@jrc.ec.europa.eu", "ec-esdac@jrc.ec.europa.eu", site.df$dataset.contact_ietf_email)
summary(as.factor(site.df$dataset.contact_ietf_email))
#visnir.df$scan.contact.email_ietf_email = ifelse(visnir.df$scan.contact.email_ietf_email=="esdac@jrc.ec.europa.eu", "ec-esdac@jrc.ec.europa.eu", visnir.df$scan.contact.email_ietf_email)
summary(as.factor(mir.df$scan.contact.email_ietf_email))
summary(duplicated(visnir.df$id.scan_uuid_c))
## OK!

saveRDS.gz(soil.df[soil.df$id.layer_uuid_c %in% id.s,], "/mnt/soilspec4gg/ossl/ossl_import/ossl_soillab_v1.rds")
saveRDS.gz(site.df[site.df$id.layer_uuid_c %in% id.s,], "/mnt/soilspec4gg/ossl/ossl_import/ossl_soilsite_v1.rds")
saveRDS.gz(visnir.df[visnir.df$id.layer_uuid_c %in% id.vnir,], "/mnt/soilspec4gg/ossl/ossl_import/ossl_visnir_v1.rds")
saveRDS.gz(mir.df[mir.df$id.layer_uuid_c %in% id.mir,], "/mnt/soilspec4gg/ossl/ossl_import/ossl_mir_v1.rds")
#rm(mir.df); gc()
#rm(visnir.df); gc()
#visnir.df = readRDS.gz("/mnt/soilspec4gg/ossl/ossl_import/ossl_visnir_v1.rds")
#mir.df = readRDS.gz("/mnt/soilspec4gg/ossl/ossl_import/ossl_mir_v1.rds")

## Overlay points and covariates ----
ov_ADMIN = readOGR("/mnt/gaia/tmp/openlandmap/tiling/tiles_GH_100km_land.gpkg")
site.p = spTransform(site.xy, ov_ADMIN@proj4string)
ID = sp::over(site.p, ov_ADMIN)
#summary(as.factor(ID$ID))
tif.lst = list.files("/data/WORLDCLIM", ".tif", full.names=TRUE)
## 122
ov.tmp = parallel::mclapply(1:length(tif.lst), function(j){ terra::extract(terra::rast(tif.lst[j]), terra::vect(site.xy)) }, mc.cores = 16)
ov.tmp = dplyr::bind_cols(lapply(ov.tmp, function(i){i[,2]}))
names(ov.tmp) = tools::file_path_sans_ext(basename(tif.lst))
## remove covariates with no variation?
c.na = sapply(ov.tmp, function(i){sum(is.na(i))})
c.sd = sapply(ov.tmp, function(i){var(i, na.rm=TRUE)})
rm.c = which(c.na>200 | c.sd == 0)
#rm.c
## summary(ov.tmp$lcv_global.seasonal.s1_earth.big.data.winter.vv.rmse_m_250m_s0..0cm_2019.12..2020.11_epsg4326_v1)
## 23 layers suspicious
## clm_snow.prob missing values for 300-400 points
ov.tmp$id.location_olc_c = site.xy$id.location_olc_c
ov.tmp$ID = ID$ID
#summary(as.factor(ov.tmp$ID))
## high clustering of points?
saveRDS.gz(ov.tmp, "/mnt/soilspec4gg/ossl/ossl_import/ov.tmp.rds")
#ov.tmp = readRDS.gz("/mnt/soilspec4gg/ossl/ossl_import/ov.tmp.rds")

## Final regression matrix ----
gc()
#soilsite = readRDS(url("http://s3.us-east-1.wasabisys.com/soilspectroscopy/ossl_import/ossl_soilsite_v1.rds", "rb"))
#soillab = readRDS(url("http://s3.us-east-1.wasabisys.com/soilspectroscopy/ossl_import/ossl_soillab_v1.rds", "rb"))
#mir = readRDS(url("http://s3.us-east-1.wasabisys.com/soilspectroscopy/ossl_import/ossl_mir_v1.rds", "rb"))
#visnir = readRDS(url("http://s3.us-east-1.wasabisys.com/soilspectroscopy/ossl_import/ossl_visnir_v1.rds", "rb"))

## create 1 regression matrix with all data
visnir.df$vnirmodel.code_any_c = paste(visnir.df$model.code_any_c)
mir.df$mirmodel.code_any_c = paste(mir.df$model.code_any_c)
sel.mir.name = c("id.layer_uuid_c", "id.scan_uuid_c", "mirmodel.code_any_c", paste0("scan_mir.", seq(600, 4000, by=2), "_abs"))
sel.vnir.name = c("id.layer_uuid_c", "vnirmodel.code_any_c", paste0("scan_visnir.", seq(350, 2500, by=2), "_pcnt"))
## takes minutes...
rm.ossl = plyr::join_all(list(soil.df[soil.df$id.layer_uuid_c %in% id.s,],
                         site.df[site.df$id.layer_uuid_c %in% id.s,-which(names(site.df)=="id.layer_local_c")],
                         mir.df[mir.df$id.layer_uuid_c %in% id.mir, sel.mir.name],
                         visnir.df[visnir.df$id.layer_uuid_c %in% id.vnir, sel.vnir.name],
                         ov.tmp))
#Joining by: id.layer_uuid_c
#Joining by: id.layer_uuid_c
#Joining by: id.layer_uuid_c
#Joining by: id.location_olc_c
#rm.ossl = rm.ossl[!is.na(rm.ossl$dataset.code_ascii_c),]
## some lab data without scans
keep.lst = !(is.na(rm.ossl$scan_mir.602_abs) & is.na(rm.ossl$scan_visnir.552_pcnt))
rm.ossl = rm.ossl[keep.lst,]
dim(rm.ossl)
## 140731   2999
summary(is.na(rm.ossl$id.layer_uuid_c))
summary(duplicated(rm.ossl$id.scan_uuid_c))
## 76,641 duplicates because some only have VISNIR
View(rm.ossl[which(duplicated(rm.ossl$id.scan_uuid_c))[1:40],1:40])
summary(duplicated(rm.ossl$id.layer_uuid_c))
## 31,848
summary(!is.na(rm.ossl$scan_mir.602_abs))
summary(!is.na(rm.ossl$scan_visnir.552_pcnt))
## replace missing block ID's
summary(is.na(rm.ossl$ID))
rm.ossl$location.address_utf8_txt = ifelse(is.na(rm.ossl$location.address_utf8_txt), "Unknown", rm.ossl$location.address_utf8_txt)
rm.ossl$ID = ifelse(is.na(rm.ossl$ID), rm.ossl$location.address_utf8_txt, rm.ossl$ID)
saveRDS.gz(rm.ossl, "/mnt/soilspec4gg/ossl/ossl_import/rm.ossl_v1.rds")
#ossl.x=rm.ossl[sample.int(nrow(rm.ossl), 3e4),]

## Golden subset conditions
## 1. No spatial clustering
## 2. No erratic values
sel.hq.mir  <- mir.df$id.layer_uuid_c[-which(mir.df$scan.mir.negfreq_ossl_pct == 0 & mir.df$scan.mir.extfreq_ossl_pct == 0)]
str(sel.hq.mir)
## 737
sel.hq.visnir  <- visnir.df$id.layer_uuid_c[-which(visnir.df$scan.visnir.negfreq_ossl_pct == 0 & visnir.df$scan.visnir.extfreq_ossl_pct == 0)]
str(sel.hq.visnir)
## 171
sel.check = which(!is.na(rm.ossl$latitude_wgs84_dd) & !is.na(rm.ossl$location.error_any_m) & rm.ossl$location.error_any_m < 1100 & (!rm.ossl$id.layer_uuid_c %in% union(sel.hq.mir, sel.hq.visnir)))
## 44,081
sel.hq.loc = unique(rm.ossl$id.location_olc_c[sel.check])
sel.hq.loc = sel.hq.loc[!is.na(sel.hq.loc)]
str(sel.hq.loc)
## 46965 locations
#summary(as.factor(sel.hq.loc))
## remove spatial clustering?
prof1 = landmap::sample.grid(site.p[which(site.p$id.location_olc_c %in% sel.hq.loc),], c(3e4, 3e4), n=1)
#l0 <- list("sp.points", site.p[site.p$id.location_olc_c %in% sel.hq.loc,], pch=1, col="red")
#l1 <- list("sp.points", prof1$subset, pch="+", col="black", cex=1.2)
#length(prof1$subset)
## 2613 locations
#spplot(prof1$grid, scales=list(draw=TRUE),
#       col.regions="grey", sp.layout=list(l0, l1))
## World map ----
if(!file.exists("img/subset.pnts_sites.png")){
  library(sf)
  gs_pnts_sf <- st_as_sf(prof1$subset[1])
  plot_gh(gs_pnts_sf, out.pdf="img/subset.pnts_sites.pdf", fill.col="cyan1")
  system("pdftoppm img/subset.pnts_sites.pdf img/subset.pnts_sites -png -f 1 -singlefile")
  system("convert -crop 1280x575+36+114 img/subset.pnts_sites.png img/subset.pnts_sites.png")
}
## Subsampling ratio in percent:
round(length(prof1$subset)/length(site.p)*100, 1)
## save image
## golden dataset:
gs.sel = which(rm.ossl$id.location_olc_c %in% sel.hq.loc[sel.hq.loc %in% prof1$subset$id.location_olc_c])
str(gs.sel)
## 21,030
saveRDS.gz(rm.ossl[gs.sel,], "./subset/rm.ossl_hq.rds")
#save.image.pigz(file="test_bind.RData", n.cores=32)
