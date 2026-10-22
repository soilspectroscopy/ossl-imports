
# pak::pak("nbafrank/uvr-r")
library("uvr")
uvr::init()

# listed_libraries <- readLines("R/_dependencies.R")
# library_pattern <- "(?:library|require)\\([\"']?([a-zA-Z0-9.]+)?[\"']?\\)"
# detected_packages <- regmatches(listed_libraries, regexec(library_pattern, listed_libraries))
# packages <- sapply(detected_packages, function(x) x[2])
# packages <- unique(packages[!is.na(packages)])
# packages

uvr::add(packages)
uvr::sync()
