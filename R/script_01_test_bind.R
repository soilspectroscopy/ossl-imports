
# site

ossl.soilsite[1:10,1:10]

ossl.soilsite %>%
   count(dataset.code_ascii_txt)

ossl.soilsite %>%
  count(code)

ossl.soilsite %>%
  glimpse()

# soil

ossl.soillab[1:10,1:10]

ossl.soillab %>%
  count(code)

ossl.soillab %>%
  glimpse()

# join soil & site data

join1 <- left_join(ossl.soilsite, ossl.soillab, by = c("code", "file_sequence", "id.layer_local_c"))
join1 %>% count(code)

join2 <- left_join(ossl.soillab, ossl.soilsite, by = c("code", "file_sequence", "id.layer_local_c"))
join2 %>% count(code)

# mir

ossl.mir %>%
  count(code)

ossl.visnir %>%
  count(code)

spectra <- full_join(ossl.mir, ossl.visnir, by = c("code", "file_sequence", "id.layer_local_c"))

spectra %>%
  count(code)

# Final join

final.join1 <- left_join(join1, spectra, by = c("code", "file_sequence", "id.layer_local_c"))
final.join2 <- left_join(join2, spectra, by = c("code", "file_sequence", "id.layer_local_c"))

final.join1 %>%
  count(code)

final.join2 %>%
  count(code)

# Checks
ossl.level0.export %>%
  mutate(incomplete_location = is.na(longitude.point_wgs84_dd)&!is.na(latitude.point_wgs84_dd)) %>%
  count(incomplete_location)

ossl.level0.export %>%
  mutate(missing_location = is.na(longitude.point_wgs84_dd)) %>%
  count(missing_location)

ossl.level0.export <- ossl.level0.export %>%
  mutate(location.point.error_any_m = ifelse(is.na(longitude.point_wgs84_dd), NA, location.point.error_any_m)) %>%
  mutate(id.layer_uuid_txt = openssl::md5(paste0(dataset.code_ascii_txt, id.layer_local_c)),
         id.location_olc_txt = olctools::encode_olc(latitude.point_wgs84_dd, longitude.point_wgs84_dd, 10)) %>%
  mutate(id.layer_uuid_txt = as.character(id.layer_uuid_txt),
         id.location_olc_txt = as.character(id.location_olc_txt)) %>%
  select(-code, -file_sequence) %>%
  relocate(id.layer_uuid_txt, .after = id.layer_local_c)

ossl.level0.export %>%
  mutate(available_mir = !is.na(scan_mir.1000_abs),
         available_visnir = !is.na(scan_visnir.1000_ref)) %>%
  count(dataset.code_ascii_txt, available_mir, available_visnir) %>%
  group_by(dataset.code_ascii_txt) %>%
  mutate(perc_dataset = round(n/sum(n)*100, 2))

ossl.level0.export %>%
  mutate(missing_location = is.na(longitude.point_wgs84_dd)) %>%
  count(dataset.code_ascii_txt, missing_location) %>%
  group_by(dataset.code_ascii_txt) %>%
  mutate(perc_dataset = round(n/sum(n)*100, 2))
