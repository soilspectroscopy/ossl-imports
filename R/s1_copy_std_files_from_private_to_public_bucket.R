
library("tidyverse")
library("fs")

private.dir <- "~/mnt-ossl-private/database/"
public.dir <- "~/mnt-ossl-public/"

datasets.path <- dir_ls(path(private.dir,"datasets/"))
datasets.code <- basename(datasets.path)

datasets.code <- grep("NEON",datasets.code, value = T)

# dir_ls(path(public.dir,"datasets/"))

# Making sure the folders exist
# for(i in 1:length(datasets.code)){
#   dir_create(path(public.dir,"datasets/",datasets.code[i]))
#   cat("Created:", datasets.code[i],"\n")
# }

# Copying standardized files
# for(i in 1:length(datasets.code)){
#   files <- dir_ls(path = path(private.dir,"datasets",datasets.code[i]),
#                   glob = "*.parquet|*.csv.gz")
#   dest_folder <- path(public.dir,"datasets/",datasets.code[i])
#   file_copy(path = files, new_path = dest_folder, overwrite = TRUE)
#   cat("Copied:", datasets.code[i],"\n")
# }

paths <- dir_ls(path(public.dir,"datasets/"), recurse = T)
paths <- grep("*.csv.gz|*.parquet", paths, value = T)
paths <- as.vector(paths)
paths <- gsub("/home/jsafanelli/mnt-ossl-public",
              "https://storage.googleapis.com/soilspec4gg-public",
              paths)

public.dataset.files <- tibble(dataset_code = basename(dirname(paths)),
                               ossl_file = basename(paths),
                               public_url = paths)

public.dataset.files

write_csv(public.dataset.files, "out/ossl_individual_datasets_urls_v1.3.csv")
