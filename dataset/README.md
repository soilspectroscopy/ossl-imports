Binding all datasets
================
Jose Lucas Safanelli (<jsafanelli@woodwellclimate.org>), Tomislav Hengl
(<tom.hengl@opengeohub.org>), Jonathan Sanderman
(<jsanderman@woodwellclimate.org>) -
06 December, 2022



-   [Description](#description)
-   [Joining and binding all
    datasets](#joining-and-binding-all-datasets)
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
Last update: 2022-12-06

All the external datasets were imported and harmonized to the OSSL
naming conventions as described in each `README` present in their
specific folders. Site, Soil, MIR, and VisNIR data were all exported to
our local server as `qs` serial files (R package `qs`). The exported
naming follows the standard
`<local DATASET folder>_<data table>_<version>.<format>`:

-   `<local DATASET folder>/ossl_soilsite_v1.2.qs`: Imported/harmonized
    site data in `qs` format.  
-   `<local DATASET folder>/ossl_soilab_v1.2.qs`: Imported/harmonized
    soil reference data in `qs` format.  
-   `<local DATASET folder>/ossl_mir_v1.2.qs`: Imported/harmonized MIR
    data in `qs` format.  
-   `<local DATASET folder>/ossl_visnir_v1.2.qs`: Imported/harmonized
    ViSNIR data in `qs` format.

## Joining and binding all datasets

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

Listing and reading `qs` files

``` r
qs.files <- dir_ls(dir, recurse = T, regexp = glob2rx("*v1.2.qs"))

qs.mir <- as.vector(grep("_mir_", qs.files, value = T))
qs.visnir <- as.vector(grep("_visnir_", qs.files, value = T))

qs.mir.ids <- tibble(file_sequence = as.character(1:length(qs.mir)), code = basename(dirname(qs.mir)))
qs.visnir.ids <- tibble(file_sequence = as.character(1:length(qs.visnir)), code = basename(dirname(qs.visnir)))
```

``` r
toc()
```

    ## 5.582 sec elapsed

``` r
rm(list = ls())
gc()
```

    ##           used  (Mb) gc trigger  (Mb) max used  (Mb)
    ## Ncells 2383095 127.3    3796570 202.8  3796570 202.8
    ## Vcells 4082115  31.2    8388608  64.0  6638101  50.7

## References
