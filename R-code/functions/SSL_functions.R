## OSSL functions

subset.ossl <- function(ossl.x, tvar.y="ph.h2o_usda.4c1_index", dataset.y, harm.x="dataset.code_ascii_c",
                        visnir.x=paste0("scan_visnir.", seq(350, 2500, by=2), "_pcnt"),
                        mir.x=paste0("scan_mir.", seq(600, 4000, by=2), "_abs"),
                        geo.x="clm_", ID="ID"){
  if(missing(ossl.x)){
    ossl.x = readRDS(url("http://s3.us-east-1.wasabisys.com/soilspectroscopy/ossl_import/rm.ossl_v1", "rb"))
  }
  if(missing(dataset.y)){
    dataset.y = levels(as.factor(ossl.x$dataset.code_ascii_c))
  }
  if(!is.null(geo.x)){
    geo.sel = names(ossl.x)[grep(geo.x, names(ossl.x))]
  } else {
    geo.sel = NULL
  }
  x.lst = c(tvar.y, harm.x, visnir.x, mir.x, geo.sel, ID)
  sel.r = complete.cases(ossl.x[,x.lst]) & ossl.x$dataset.code_ascii_c %in% dataset.y
  out = ossl.x[sel.r,x.lst]
  if(!is.null(harm.x)){
    out <- fastDummies::dummy_cols(out, select_columns = harm.x)[,-which(names(out)==harm.x)]
  }
  ## remove layers that have no variation
  c.sd = sapply(out[,-which(names(out)==ID)], function(i){var(i, na.rm=TRUE)})
  c.r = which(c.sd == 0)
  if(length(c.r)>0){
    out = out[,-c.r]
  }
  return(out)
}

## Target variables
# site.name = c("id.location_olc_c", "id.layer_uuid_c", "observation.ogc.schema.title_ogc_txt",
#               "observation.ogc.schema_idn_url", "observation.date.begin_iso.8601_yyyy.mm.dd",
#               "observation.date.end_iso.8601_yyyy.mm.dd", "location.address_utf8_txt", "location.country_iso.3166_c",
#               "location.method_any_c", "surveyor.title_utf8_txt", "surveyor.contact_ietf_email",
#               "surveyor.address_utf8_txt", "longitude_wgs84_dd", "latitude_wgs84_dd",
#               "location.error_any_m", "dataset.title_utf8_txt", "dataset.owner_utf8_txt",
#               "dataset.code_ascii_c", "dataset.address_idn_url",
#               "dataset.license.title_ascii_txt", "dataset.license.address_idn_url", "dataset.doi_idf_c",
#               "dataset.contact.name_utf8_txt", "dataset.contact_ietf_email", "id.project_ascii_c",
#               "id.user.site_ascii_c", "pedon.taxa_usda_c", "pedon.completeness_usda_uint8",
#               "layer.sequence_usda_uint16", "layer.type_usda_c", "layer.field.label_any_c",
#               "layer.upper.depth_usda_cm", "layer.lower.depth_usda_cm", "horizon.designation_usda_c",
#               "horizon.designation.discontinuity_usda_c", "layer.structure.type_usda_c",
#               "layer.structure.grade_usda_c", "layer.texture_usda_c")
#
# soilab.name = c("id.layer_uuid_c", "id.layer_local_c", "sample.doi_idf_c", "sample.contact.name_utf8_txt",
#                 "sample.contact.email_ietf_email", "acid.tea_usda4b2_cmolkg", "al.dith_usda.4g1_wpct",
#                 "al.kcl_usda.4b3_cmolkg", "al.ox_usda.4g2_wpct", "bsat_usda.4b4_wpct",
#                 "bd.clod_usda.3b1_gcm3", "bd.od_usda.3b2_gcm3", "ca.ext_usda.4b1_cmolkg", "c.tot_usda.4h2_wpct",
#                 "caco3_usda.4e1_wpct", "cec.ext_usda.4b1_cmolkg", "gyp_usda.4e2_wpct",
#                 "ecec_usda.4b4_cmolkg", "ec.w_usda.4f1_dsm", "oc_usda.calc_wpct", "fe.dith_usda.4g1_wpct",
#                 "fe.kcl_usda.4b3_mgkg", "fe.ox_usda.4g2_wpct", "mg.ext_usda.4b1_cmolkg", "n.tot_usda.4h2_wpct",
#                 "ph.kcl_usda.4c1_index", "ph.h2o_usda.4c1_index", "ph.cacl2_usda.4c1_index",
#                 "ph.naf_usda.4c1_index", "p.ext_usda.4d6_mgkg", "p.olsn_usda.4d5_mgkg",
#                 "k.ext_usda.4b1_cmolkg", "sand.tot_usda.3a1_wpct", "wpg2_usda.3a2_wpct",
#                 "silt.tot_usda.3a1_wpct", "clay.tot_usda.3a1_wpct", "na.ext_usda.4b1_cmolkg",
#                 "s.tot_usda.4h2_wpct", "sum.bases_4b4b2a_cmolkg", "wr.33kbar_usda.3c1_wpct",
#                 "wr.1500kbar_usda.3c2_wpct", "al.meh3_usda.4d6_wpct", "as.meh3_usda.4d6_mgkg",
#                 "ba.meh3_usda.4d6_mgkg", "ca.meh3_usda.4d6_mgkg", "cd.meh3_usda.4d6_wpct",
#                 "co.meh3_usda.4d6_mgkg", "cr.meh3_usda.4d6_mgkg", "cu.meh3_usda.4d6_mgkg",
#                 "p.meh3_usda.4d6_mgkg", "k.meh3_usda.4d6_mgkg", "na.meh3_usda.4d6_mgkg",
#                 "mg.meh3_usda.4d6_mgkg", "fe.meh3_usda.4d6_mgkg", "pb.meh3_usda.4d6_mgkg",
#                 "zn.meh3_usda.4d6_mgkg", "mo.meh3_usda.4d6_mgkg", "si.meh3_usda.4d6_mgkg",
#                 "sr.meh3_usda.4d6_mgkg")
#
# mir.name = c("id.scan_uuid_c", "id.scan_local_c", "id.layer_uuid_c", "id.layer_local_c", "model.name_utf8_txt",
#              "model.code_any_c", "method.light.source_any_c",
#              "method.preparation_any_c", "scan.file_any_c", "scan.date.begin_iso.8601_yyyy.mm.dd",
#              "scan.date.end_iso.8601_yyyy.mm.dd", "scan.license.title_ascii_txt", "scan.license.address_idn_url",
#              "scan.doi_idf_c", "scan.contact.name_utf8_txt", "scan.contact.email_ietf_email",
#              "scan.mir.nafreq_ossl_pct", "scan.mir.negfreq_ossl_pct", "scan.mir.extfreq_ossl_pct",
#              paste0("scan_mir.", seq(600, 4000, by=2), "_abs"))
#
# visnir.name = c("id.scan_uuid_c", "id.scan_local_c", "id.layer_uuid_c", "id.layer_local_c", "model.name_utf8_txt",
#                 "model.code_any_c", "method.light.source_any_c", "method.preparation_any_c",
#                 "scan.file_any_c", "scan.date.begin_iso.8601_yyyy.mm.dd", "scan.date.end_iso.8601_yyyy.mm.dd",
#                 "scan.license.title_ascii_txt", "scan.license.address_idn_url", "scan.doi_idf_c",
#                 "scan.contact.name_utf8_txt", "scan.contact.email_ietf_email",
#                 "scan.visnir.nafreq_ossl_pct", "scan.visnir.negfreq_ossl_pct", "scan.visnir.extfreq_ossl_pct",
#                 paste0("scan_visnir.", seq(350, 2500, by=2), "_pcnt"))

## Function to find a mode
Mode <- function(x) {
  ux <- unique(x)
  ux[which.max(tabulate(match(x, ux)))]
}

## Translate names
transform_values = function(df, out.name, in.name, fun.lst){
  if(!length(out.name)==length(in.name)){
    stop("Arguments 'out.name' and 'in.name' not equal length")
  }
  if(missing(fun.lst)){
    fun.lst = as.list(rep("x*1", length(out.name)))
  }
  ## https://stackoverflow.com/questions/61094854/storing-functions-in-an-r-list
  utility.fns = lapply(1:length(fun.lst), function(i){function(x){eval(parse(text = fun.lst[[i]]) )}})
  out <- as.data.frame(lapply(1:length(in.name), function(i){utility.fns[[i]](df[,in.name[i]])}))
  names(out) = out.name
  return(out)
}


saveRDS.gz <- function(object,file,threads=parallel::detectCores()) {
  con <- pipe(paste0("pigz -p",threads," > ",file),"wb")
  saveRDS(object, file = con)
  close(con)
}

readRDS.gz <- function(file,threads=parallel::detectCores()) {
  con <- pipe(paste0("pigz -d -c -p",threads," ",file))
  object <- readRDS(file = con)
  close(con)
  return(object)
}

hor2xyd <- function(x, U="UHDICM", L="LHDICM", treshold.T=15){
  x$DEPTH <- x[,U] + (x[,L] - x[,U])/2
  x$THICK <- x[,L] - x[,U]
  sel <- x$THICK < treshold.T
  ## begin and end of the horizon:
  x1 <- x[!sel,]; x1$DEPTH = x1[,L]
  x2 <- x[!sel,]; x2$DEPTH = x1[,U]
  y <- do.call(rbind, list(x, x1, x2))
  return(y)
}

plot_gh <- function(pnts, output, world, lats, longs, crs_goode = "+proj=igh", fill.col = "yellow"){

  # https://wilkelab.org/practicalgg/articles/goode.html
  require(cowplot)
  require(sf)
  require(rworldmap)
  require(ggplot2)

  if(missing(world)){ world <- sf::st_as_sf(rworldmap::getMap(resolution = "low")) }

  if(missing(lats)){
    lats <- c(
      90:-90, # right side down
      -90:0, 0:-90, # third cut bottom
      -90:0, 0:-90, # second cut bottom
      -90:0, 0:-90, # first cut bottom
      -90:90, # left side up
      90:0, 0:90, # cut top
      90 # close
    )
  }

  if(missing(longs)){
    longs <- c(
      rep(180, 181), # right side down
      rep(c(80.01, 79.99), each = 91), # third cut bottom
      rep(c(-19.99, -20.01), each = 91), # second cut bottom
      rep(c(-99.99, -100.01), each = 91), # first cut bottom
      rep(-180, 181), # left side up
      rep(c(-40.01, -39.99), each = 91), # cut top
      180 # close
    )
  }

  goode_outline <-
    list(cbind(longs, lats)) %>%
    st_polygon() %>%
    st_sfc(
      crs = "+proj=longlat +ellps=WGS84 +datum=WGS84 +no_defs"
    )

  # now we need to work in transformed coordinates, not in long-lat coordinates
  goode_outline <- st_transform(goode_outline, crs = crs_goode)

  # get the bounding box in transformed coordinates and expand by 10%
  xlim <- st_bbox(goode_outline)[c("xmin", "xmax")]*1.1
  ylim <- st_bbox(goode_outline)[c("ymin", "ymax")]*1.1

  # turn into enclosing rectangle
  goode_encl_rect <-
    list(
      cbind(
        c(xlim[1], xlim[2], xlim[2], xlim[1], xlim[1]),
        c(ylim[1], ylim[1], ylim[2], ylim[2], ylim[1])
      )
    ) %>%
    st_polygon() %>%
    st_sfc(crs = crs_goode)

  # calculate the area outside the earth outline as the difference
  # between the enclosing rectangle and the earth outline
  goode_without <- st_difference(goode_encl_rect, goode_outline)

  m <- ggplot(world) +
    geom_sf(fill = "gray80", color = "black", size = 0.5/.pt) +
    geom_sf(data = goode_without, fill = "white", color = "NA") +
    geom_sf(data = goode_outline, fill = NA, color = "gray30", size = 0.5/.pt) +
    geom_sf(data = pnts, fill = fill.col, color = "black", size = 0.8, shape = 21, stroke = 0.12) +
    # geom_sf(data = pnts, size = 0.8, shape = 21, fill = fill.col, color = "black") +
    # geom_sf(data = pnts, size = 1, pch="+", color="black") +
    coord_sf(crs = crs_goode, xlim = 0.95*xlim, ylim = 0.95*ylim, expand = FALSE) +
    cowplot::theme_minimal_grid() +
    theme(panel.background = element_rect(fill = "#56B4E950", color = "white", size = 1),
          panel.grid.major = element_line(color = "gray30", size = 0.25))

  ggsave(output, m, dpi = 200, units = "in", height = 4.5, width = 10)

}

