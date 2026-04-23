
library("googledrive")
library("fs")
library("purrr")

drive_auth(path = "~/secrets/soilcarbon-soilspec-845d0d3f2fbe.json")

#### AFSIS1 #####

dir_ls("~/")
dir_ls("~/mnt-ossl-private/database/datasets/")
# dir_create("~/mnt-ossl-private/database/datasets/AFSIS1")
# dir_ls("~/mnt-ossl-private/database/datasets/")

print(drive_get(as_id("1l9VM4fFks2xBloDE69EFTfPgQeFx5aGw")), n=Inf)
print(drive_ls(as_id("1l9VM4fFks2xBloDE69EFTfPgQeFx5aGw"), type = "folder"), n=Inf)
print(drive_ls(as_id("17f3BUS53XK1mnRVTeazpO9BRoPDP4xpB"), n=Inf))
print(drive_ls(as_id("14FN1dcgTBZi6I25eW8kXopRihWHmSIAd"), n=Inf))

# # AfSIS_reference.csv
# drive_download(file = as_id("1rR7SUAv4tLfhsZjk2VuaVz5T_Dyo8ZsO"),
#                path = "~/mnt-ossl-private/database/datasets/AFSIS1/AfSIS_reference.csv",
#                overwrite = T, verbose = T)
#
# # Calibration_MPA_NIR.csv
# drive_download(file = as_id("1T47YFgz2GY8gUaqGW526pEUhuI_xOLQe"),
#                path = "~/mnt-ossl-private/database/datasets/AFSIS1/Calibration_MPA_NIR.csv",
#                overwrite = T, verbose = T)
#
# # georeferences_2013.csv
# drive_download(file = as_id("1v_GTanz9DT1Q_HRoYlhCdhIMMkDn9Sj5"),
#                path = "~/mnt-ossl-private/database/datasets/AFSIS1/georeferences_2013.csv",
#                overwrite = T, verbose = T)
#
# # Multiple NIR files inside 'afsis_mir_2013'
# download_files <- drive_ls(as_id("16jZeZ9jKJ9Iut56r1N1hTlh5GRtyIB_d"), n=Inf)
#
# dir_create("~/mnt-ossl-private/database/datasets/AFSIS1/afsis_mir_2013")
#
# walk2(.x = download_files$id,
#       .y = download_files$name,
#       .f = ~drive_download(file = as_id(.x),
#                            path = path("~/mnt-ossl-private/database/datasets/AFSIS1/afsis_mir_2013", .y),
#                            overwrite = T, verbose = T))

#### AFSIS2 #####

dir_ls("~/")
dir_ls("~/mnt-ossl-private/database/datasets/")
# dir_create("~/mnt-ossl-private/database/datasets/AFSIS2")
# dir_ls("~/mnt-ossl-private/database/datasets/")

print(drive_get(as_id("1l9VM4fFks2xBloDE69EFTfPgQeFx5aGw")), n=Inf)
print(drive_ls(as_id("1l9VM4fFks2xBloDE69EFTfPgQeFx5aGw"), type = "folder"), n=Inf)
print(drive_ls(as_id("1r5cXEuvuWRhhzkAFw3ABZ1YBZu8c-Skq"), n=Inf))

# drive_download(file = as_id("1iFLvOj4ETzdRaaiz5Om04p0DqRv0vZiJ"),
#                path = "~/mnt-ossl-private/database/datasets/AFSIS2/AFSIS2.zip",
#                overwrite = T, verbose = T)
#
# unzip(zipfile = "~/mnt-ossl-private/database/datasets/AFSIS2/AFSIS2.zip", list=T)
#
# unzip(zipfile = "~/mnt-ossl-private/database/datasets/AFSIS2/AFSIS2.zip",
#       exdir = "~/mnt-ossl-private/database/datasets/AFSIS2/", junkpaths = T)

dir_ls("~/mnt-ossl-private/database/datasets/AFSIS2/")

#### CAF ####

dir_ls("~/")
cat(dir_ls("~/mnt-ossl-private/database/datasets/"), sep = "\n")
cat(dir_ls("~/mnt-ossl-private/database/datasets/CAF"), sep = "\n")

#### PlantedForests_NewZealand ####

dir_ls("~/")
cat(dir_ls("~/mnt-ossl-private/database/datasets/"), sep = "\n")
dir_create("~/mnt-ossl-private/database/datasets/PlantedForests_NewZealand")
cat(dir_ls("~/mnt-ossl-private/database/datasets/"), sep = "\n")

print(drive_get(as_id("1l9VM4fFks2xBloDE69EFTfPgQeFx5aGw")), n=Inf)
print(drive_ls(as_id("1l9VM4fFks2xBloDE69EFTfPgQeFx5aGw")), n=Inf)
print(drive_ls(as_id("15UCzVjsLIcg_XKsW3yLIppwzQRGAeAAs"), n=Inf))

# drive_download(file = as_id("1AI9Vbszdo8qRWUnUhwyEOrJtKTgeJ__I"),
#                path = "~/mnt-ossl-private/database/datasets/PlantedForests_NewZealand/Garrett.zip",
#                overwrite = T, verbose = T)
#
# unzip(zipfile = "~/mnt-ossl-private/database/datasets/PlantedForests_NewZealand/Garrett.zip",
#       list=T)
#
# all_files <- unzip("~/mnt-ossl-private/database/datasets/PlantedForests_NewZealand/Garrett.zip", list = TRUE)$Name
# files_to_extract <- all_files[!grepl("\\.(0|jpg|JPG|tif|GIF)$", all_files, ignore.case = TRUE)]
#
# unzip("~/mnt-ossl-private/database/datasets/PlantedForests_NewZealand/Garrett.zip",
#       files = files_to_extract,
#       exdir = "~/mnt-ossl-private/database/datasets/PlantedForests_NewZealand/")
#
# dir_ls("~/mnt-ossl-private/database/datasets/PlantedForests_NewZealand/")

# src <- "/home/jsafanelli/mnt-ossl-private/database/datasets/PlantedForests_NewZealand/Garrett"
# dest <- "/home/jsafanelli/mnt-ossl-private/database/datasets/PlantedForests_NewZealand"
# items <- list.files(src, full.names = TRUE, recursive = T)
# new_items <- gsub("/Garrett", "", items)
# dir_create("~/mnt-ossl-private/database/datasets/PlantedForests_NewZealand/FR380_MIR spectra_csv")
# for(i in 1:length(items)){file_move(items[i], new_items[i])}
# dir_delete("~/mnt-ossl-private/database/datasets/PlantedForests_NewZealand/Garrett")

dir_ls("~/mnt-ossl-private/database/datasets/PlantedForests_NewZealand/")

#### ICRAF_ISRIC ####

dir_ls("~/")
cat(dir_ls("~/mnt-ossl-private/database/datasets/"), sep = "\n")
dir_create("~/mnt-ossl-private/database/datasets/ICRAF_ISRIC")
cat(dir_ls("~/mnt-ossl-private/database/datasets/"), sep = "\n")

print(drive_get(as_id("1l9VM4fFks2xBloDE69EFTfPgQeFx5aGw")), n=Inf)
print(drive_ls(as_id("1l9VM4fFks2xBloDE69EFTfPgQeFx5aGw")), n=Inf)
print(drive_ls(as_id("1E2mEQqMqqCecG_iq1CXq2kXXYLi-Raf-"), n=Inf))

# drive_download(file = as_id("1HoAP-Nr9mvq62lK4ZDYExHfLt66nUS9M"),
#                path = "~/mnt-ossl-private/database/datasets/ICRAF_ISRIC/ICRAF_ISRIC.zip",
#                overwrite = T, verbose = T)
#
# unzip(zipfile = "~/mnt-ossl-private/database/datasets/ICRAF_ISRIC/ICRAF_ISRIC.zip", list=T)
#
# all_files <- unzip(zipfile = "~/mnt-ossl-private/database/datasets/ICRAF_ISRIC/ICRAF_ISRIC.zip", list=T)$Name
# files_to_extract <- all_files[grepl("ICRAF_ISRIC_reference_data|ICRAF_ISRIC_VNIR_spectra.csv|ICRAF_ISRIC_MIR_spectra.csv", all_files, ignore.case = TRUE)]
#
# unzip(zipfile = "~/mnt-ossl-private/database/datasets/ICRAF_ISRIC/ICRAF_ISRIC.zip",
#       files = files_to_extract,
#       exdir = "~/mnt-ossl-private/database/datasets/ICRAF_ISRIC/")

# src <- "/home/jsafanelli/mnt-ossl-private/database/datasets/ICRAF_ISRIC/ICRAF_ISRIC/"
# dest <- "/home/jsafanelli/mnt-ossl-private/database/datasets/ICRAF_ISRIC/"
# items <- dir_ls(src, full.names = TRUE)
# new_items <- gsub("/ICRAF_ISRIC/ICRAF_ISRIC/", "/ICRAF_ISRIC/", items)
# for(i in 1:length(items)){file_move(items[i], new_items[i])}
# dir_delete("~/mnt-ossl-private/database/datasets/ICRAF_ISRIC/ICRAF_ISRIC")

#### ICRAF_ISRIC ####

dir_ls("~/")
cat(dir_ls("~/mnt-ossl-private/database/datasets/"), sep = "\n")
dir_create("~/mnt-ossl-private/database/datasets/KSSL/")
cat(dir_ls("~/mnt-ossl-private/database/datasets/"), sep = "\n")

print(drive_get(as_id("1l9VM4fFks2xBloDE69EFTfPgQeFx5aGw")), n=Inf)
print(drive_ls(as_id("1l9VM4fFks2xBloDE69EFTfPgQeFx5aGw")), n=Inf)
print(drive_ls(as_id("1GdeqV7wLLeMMP8U7roxOcKjEOfR2FlTe"), n=Inf))
print(drive_ls(as_id("1SSQoRBqHImWf420Lq0boixMJlnTQ_J-a"), n=Inf))
print(drive_ls(as_id("1UT9mdPQ2Nf5ex0qvjx4LGSyiZED_maSB"), n=Inf))

# VNIR RaCA spectra
# drive_download(file = as_id("1qcBogfdxVdjrZlCtwFVqyv-P7b3WFcDI"),
#                path = "~/mnt-ossl-private/database/datasets/KSSL/RaCA_measured.csv",
#                overwrite = T, verbose = T)

# MIR spectra
print(drive_ls(as_id("1XvFWWev8Nq4goVAHEZpSD6rZm9oThh-w"), n=Inf))
print(drive_ls(as_id("14vHRc3hA1Xs4mDXupXif7_5FA2kccwK5"), n=Inf))

# drive_download(file = as_id("1HG7z8H7_76gRUKz1pso4O1wxtJ4TDU14"),
#                path = "~/mnt-ossl-private/database/datasets/KSSL/KSSL_202207_MIR_spectra_all_avg_clean.csv",
#                overwrite = T, verbose = T)

# Database files
print(drive_ls(as_id("1XvFWWev8Nq4goVAHEZpSD6rZm9oThh-w"), n=Inf))
print(drive_ls(as_id("1IzwDcbusEJ6IjXioXtY7AILvAHfQ0xSW"), n=Inf))

# Multiple NIR files inside 'All_Spectra_Access_Portable_20220712'
download_files <- drive_ls(as_id("1IzwDcbusEJ6IjXioXtY7AILvAHfQ0xSW"), n=Inf)

# dir_create("~/mnt-ossl-private/database/datasets/KSSL/All_Spectra_Access_Portable_20220712")
#
# walk2(.x = download_files$id,
#       .y = download_files$name,
#       .f = ~drive_download(file = as_id(.x),
#                            path = path("~/mnt-ossl-private/database/datasets/KSSL/All_Spectra_Access_Portable_20220712", .y),
#                            overwrite = T, verbose = T))

#### LUCAS ####

dir_ls("~/")
cat(dir_ls("~/mnt-ossl-private/database/datasets/"), sep = "\n")
dir_create("~/mnt-ossl-private/database/datasets/LUCAS/")
cat(dir_ls("~/mnt-ossl-private/database/datasets/"), sep = "\n")

print(drive_get(as_id("1l9VM4fFks2xBloDE69EFTfPgQeFx5aGw")), n=Inf)
print(drive_ls(as_id("1l9VM4fFks2xBloDE69EFTfPgQeFx5aGw")), n=Inf)
print(drive_ls(as_id("1wYz4mJ_DDMcH_K0iTgZNnwXzx1Y8vaDQ")), n=Inf)
print(drive_ls(as_id("1npIzFNd8VZDLO799PHtPDGUPc5skEq_Z")), n=Inf)

# LUCAS.SOIL_corr.Rdata: 1bCYyIAWFY0YrmGTHOeXh2bkx8peJzhTK
# LUCAS_Topsoil_2009_ESPG4326.csv: 1T43NlRatpkSj3a2pRTzXQq9nChVCniT-
# LUCAS_spectra_2015.rds: 1qgzPVrz3a6JBFXbT54v5DUJpQcsUQ3rK
# LUCAS_Topsoil_complete_2015_ESPG4326.csv: 1A0uH7NSuyScIRs_0oiz4v49e5Vu4tenW
# All with pgkg extension

# Multiple files
download_files <- drive_ls(as_id("1npIzFNd8VZDLO799PHtPDGUPc5skEq_Z"), n=Inf)

# download_files <- download_files %>%
#   dplyr::filter(grepl(".gpkg", name) | name %in% c("LUCAS.SOIL_corr.Rdata",
#                                                    "LUCAS_Topsoil_2009_ESPG4326.csv",
#                                                    "LUCAS_spectra_2015.rds",
#                                                    "LUCAS_Topsoil_complete_2015_ESPG4326.csv"))
#
# walk2(.x = download_files$id,
#       .y = download_files$name,
#       .f = ~drive_download(file = as_id(.x),
#                            path = path("~/mnt-ossl-private/database/datasets/LUCAS", .y),
#                            overwrite = T, verbose = T))

#### Neospectra ####

dir_ls("~/")
cat(dir_ls("~/mnt-ossl-private/database/datasets/"), sep = "\n")
dir_create("~/mnt-ossl-private/database/datasets/Neospectra/")
cat(dir_ls("~/mnt-ossl-private/database/datasets/"), sep = "\n")

print(drive_get(as_id("1l9VM4fFks2xBloDE69EFTfPgQeFx5aGw")), n=Inf)
print(drive_ls(as_id("1l9VM4fFks2xBloDE69EFTfPgQeFx5aGw")), n=Inf)
print(drive_ls(as_id("14CPNgelVHNc67iWx_-95qU8HBFNBWSS1")), n=Inf)

# drive_download(file = as_id("13N77QHuuRxhvyDlh1UWKMd3qGHnIc5Lf"),
#                path = "~/mnt-ossl-private/database/datasets/Neospectra.zip",
#                overwrite = T, verbose = T)
#
# unzip(zipfile = "~/mnt-ossl-private/database/datasets/Neospectra.zip", list=T)
#
# unzip(zipfile = "~/mnt-ossl-private/database/datasets/Neospectra.zip",
#       exdir = "~/mnt-ossl-private/database/datasets/")
#
# file_move("~/mnt-ossl-private/database/datasets/Neospectra.zip",
#           "~/mnt-ossl-private/database/datasets/Neospectra/Neospectra.zip")

#### HighLatitudeForests_NorthCanada ####

dir_ls("~/")
cat(dir_ls("~/mnt-ossl-private/database/datasets/"), sep = "\n")
dir_create("~/mnt-ossl-private/database/datasets/HighLatitudeForests_NorthCanada/")
cat(dir_ls("~/mnt-ossl-private/database/datasets/"), sep = "\n")

print(drive_get(as_id("1l9VM4fFks2xBloDE69EFTfPgQeFx5aGw")), n=Inf)
print(drive_ls(as_id("1l9VM4fFks2xBloDE69EFTfPgQeFx5aGw")), n=Inf)
print(drive_ls(as_id("1HfKDkhS7XCqc2GjxUM0guhzKxyoteBy9")), n=Inf)

# drive_download(file = as_id("1Aw8KnEGVVO7zGQFZUmVIXjill9RT1zrx"),
#                path = "~/mnt-ossl-private/database/datasets/Schiedung.zip",
#                overwrite = T, verbose = T)
#
# unzip(zipfile = "~/mnt-ossl-private/database/datasets/Schiedung.zip", list=T)
#
# all_files <- unzip(zipfile = "~/mnt-ossl-private/database/datasets/Schiedung.zip", list=T)$Name
# files_to_extract <- all_files[!grepl("OPUS_files|dpt_files", all_files, ignore.case = TRUE)]
#
# unzip(zipfile = "~/mnt-ossl-private/database/datasets/Schiedung.zip",
#       files = files_to_extract,
#       exdir = "~/mnt-ossl-private/database/datasets/")
#
# file_move("~/mnt-ossl-private/database/datasets/Schiedung.zip",
#           "~/mnt-ossl-private/database/datasets/HighLatitudeForests_NorthCanada/Schiedung.zip")
#
# items <- dir_ls("~/mnt-ossl-private/database/datasets/Schiedung/", full.names = TRUE)
# new_items <- gsub("/Schiedung/", "/HighLatitudeForests_NorthCanada/", items)
# for(i in 1:length(items)){file_move(items[i], new_items[i])}
# dir_delete("~/mnt-ossl-private/database/datasets/Schiedung")

#### Serbian ####

dir_ls("~/")
cat(dir_ls("~/mnt-ossl-private/database/datasets/"), sep = "\n")
dir_create("~/mnt-ossl-private/database/datasets/Serbian/")
cat(dir_ls("~/mnt-ossl-private/database/datasets/"), sep = "\n")

print(drive_get(as_id("1l9VM4fFks2xBloDE69EFTfPgQeFx5aGw")), n=Inf)
print(drive_ls(as_id("1l9VM4fFks2xBloDE69EFTfPgQeFx5aGw")), n=Inf)
print(drive_ls(as_id("1_lDtb7grO5SbTIHw1c3VmxPhh9BEWVhf")), n=Inf)

# drive_download(file = as_id("14YX1A8DI4p7bnEX08H5K-3-t4LuQkbaW"),
#                path = "~/mnt-ossl-private/database/datasets/Serbian.zip",
#                overwrite = T, verbose = T)
#
# unzip(zipfile = "~/mnt-ossl-private/database/datasets/Serbian.zip", list=T)
#
# unzip(zipfile = "~/mnt-ossl-private/database/datasets/Serbian.zip",
#       exdir = "~/mnt-ossl-private/database/datasets")
#
# file_move("~/mnt-ossl-private/database/datasets/Serbian.zip",
#           "~/mnt-ossl-private/database/datasets/Serbian/Serbian.zip")
#
# items <- dir_ls("~/mnt-ossl-private/database/datasets/Serbia/", full.names = TRUE)
# new_items <- gsub("/Serbia/", "/Serbian/", items)
# for(i in 1:length(items)){file_move(items[i], new_items[i])}
# dir_delete("~/mnt-ossl-private/database/datasets/Serbia")
