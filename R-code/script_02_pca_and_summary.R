
## Loading packages

library("tidyverse")
library("tidymodels")
library("data.table")
library("fs")
library("qs")
library("future")
library("foreach")

## Folders

dir.input <- "/mnt/soilspec4gg/ossl/dataset"
dir.figures <- "img/"
dir.output <- "out/"

## Listing datasets

qs.files <- dir_ls(dir.input, recurse = T, regexp = glob2rx("*v1.2.qs"))

qs.mir <- as.vector(grep("ossl_mir_", qs.files, value = T))
qs.visnir <- as.vector(grep("ossl_visnir_", qs.files, value = T))

qs.mir.ids <- tibble(file_sequence = as.character(1:length(qs.mir)), code = basename(dirname(qs.mir)))
qs.visnir.ids <- tibble(file_sequence = as.character(1:length(qs.visnir)), code = basename(dirname(qs.visnir)))

##################
##### visnir #####
##################

## Reading files

ossl.visnir.columns <- as.character(paste0("scan_visnir.", seq(400, 2500, by = 2), "_ref"))
id.columns <- c("code", "id.layer_local_c")

ossl.visnir <- map_dfr(.x = qs.visnir,
                       .f = qread,
                       .id= "file_sequence") %>%
  left_join(qs.visnir.ids, by = "file_sequence") %>%
  select(all_of(id.columns), all_of(ossl.visnir.columns)) %>%
  mutate_at(vars(all_of(ossl.visnir.columns)), as.numeric)

## Rename
new.spec.range <- gsub("scan_visnir.|_ref", "", ossl.visnir.columns)

ossl.visnir <- ossl.visnir %>%
  rename_with(~new.spec.range, all_of(ossl.visnir.columns))

## Preprocess with SNV
ossl.visnir.prep <- ossl.visnir %>%
  select(all_of(new.spec.range)) %>%
  as.matrix() %>%
  prospectr::standardNormalVariate(X = .) %>%
  as_tibble() %>%
  bind_cols({ossl.visnir %>%
      select(all_of(id.columns))}, .) %>%
  select(all_of(id.columns), all_of(new.spec.range)) %>%
  as_tibble()

## Train and test spectra

ossl.visnir.prep %>%
  distinct(code)

visnir.train.spectra <- ossl.visnir.prep %>%
  filter(code == "KSSL")

visnir.test.spectra <- ossl.visnir.prep %>%
  filter(!(code == "KSSL"))

# PCA of reference set, i.e. KSSL

visnir.pca.model <- visnir.train.spectra %>%
  recipe() %>%
  update_role(everything()) %>%
  update_role(all_of(id.columns), new_role = "id") %>%
  step_normalize(all_predictors(), id = "normalization") %>%
  step_pca(all_predictors(), num_comp = 4, id = "pca") %>%
  prep()

# KSSL PC space

visnir.pca.scores.train <- juice(visnir.pca.model) %>%
  rename_at(vars(starts_with("PC")), ~paste0("PC", as.numeric(gsub("PC", "", .))))

p.visnir.scores.pc1.pc2 <- visnir.pca.scores.train %>%
  ggplot(aes(x = PC1, y = PC2, color = code)) +
  geom_point(size = 0.25, alpha = 0.25) +
  labs(x = "PC1", y = "PC2", color = "") +
  theme_light() +
  theme(legend.position = "bottom")

# # Loadings
#
# visnir.pca.loadings.train <- tidy(visnir.pca.model, id = "pca", type = "coef") %>%
#   select(-id) %>%
#   filter(component %in% names(visnir.pca.scores.train)) %>%
#   pivot_wider(values_from = "value", names_from = "component")
#
# p.visnir.loading <- visnir.pca.loadings.train %>%
#   pivot_longer(-terms, names_to = "PC", values_to = "loading") %>%
#   ggplot(aes(x = as.numeric(terms), y = loading, group = PC)) +
#   geom_line(size = 0.5) +
#   facet_wrap(~PC, ncol = 1) +
#   labs(x = bquote("Wavenumber"~cm^-1), y = "PCA loading",
#        title = "Training loadings") +
#   scale_x_continuous(breaks = c(350, 500, 1000, 1500, 2000, 2500)) +
#   theme_light()

# Explained variance

visnir.pca.variance.train <- tidy(visnir.pca.model, id = "pca", type = "variance") %>%
  select(-id)

visnir.pca.xve <- visnir.pca.variance.train %>%
  filter(terms == "percent variance") %>%
  filter(component <= 4) %>%
  mutate(value = round(value, 2)) %>%
  pull(value)

# Project other datasets onto KSSL PC space

visnir.pca.scores.test <- bake(visnir.pca.model, new_data = visnir.test.spectra) %>%
  rename_at(vars(starts_with("PC")), ~paste0("PC", as.numeric(gsub("PC", "", .)))) %>%
  select(-all_of(id.columns)) %>%
  bind_cols({visnir.test.spectra %>%
      select(all_of(id.columns))}, .)

p.visnir.scores.projected.pc1.pc2 <- p.visnir.scores.pc1.pc2 +
  geom_point(data = visnir.pca.scores.test,
             aes(x = PC1, y = PC2, color = code), size = 0.50, alpha = 0.25) +
  scale_color_manual(values = c("salmon", "black", "green")) +
  labs(x = paste0("PC1 (", visnir.pca.xve[1], "%)"),
       y = paste0("PC2 (", visnir.pca.xve[2], "%)")) +
  theme_light() +
  theme(legend.position = "bottom")

p.visnir.scores.projected.pc1.pc2

ggsave(paste0(dir.figures, paste0("plot_pca_scores_visnir_ossl.png")),
       p.visnir.scores.projected.pc1.pc2, dpi = 300, width = 8, height = 6,
       units = "in", scale = 0.75)

###############
##### mir #####
###############

## Reading files

ossl.mir.columns <- as.character(paste0("scan_mir.", seq(600, 4000, by = 2), "_abs"))
id.columns <- c("code", "id.layer_local_c")

ossl.mir <- map_dfr(.x = qs.mir,
                    .f = qread,
                    .id= "file_sequence") %>%
  left_join(qs.mir.ids, by = "file_sequence") %>%
  select(all_of(id.columns), all_of(ossl.mir.columns)) %>%
  mutate_at(vars(all_of(ossl.mir.columns)), as.numeric)

## Rename
new.spec.range <- gsub("scan_mir.|_abs", "", ossl.mir.columns)

ossl.mir <- ossl.mir %>%
  rename_with(~new.spec.range, all_of(ossl.mir.columns))

## Preprocess with SNV
ossl.mir.prep <- ossl.mir %>%
  select(all_of(new.spec.range)) %>%
  as.matrix() %>%
  prospectr::standardNormalVariate(X = .) %>%
  as_tibble() %>%
  bind_cols({ossl.mir %>%
      select(all_of(id.columns))}, .) %>%
  select(all_of(id.columns), all_of(new.spec.range)) %>%
  as_tibble()

## Train and test spectra
ossl.mir.prep %>%
  distinct(code)

mir.train.spectra <- ossl.mir.prep %>%
  filter(code == "KSSL")

mir.test.spectra <- ossl.mir.prep %>%
  filter(!(code == "KSSL"))

# PCA of reference set, i.e. KSSL

mir.pca.model <- mir.train.spectra %>%
  recipe() %>%
  update_role(everything()) %>%
  update_role(all_of(id.columns), new_role = "id") %>%
  step_normalize(all_predictors(), id = "normalization") %>%
  step_pca(all_predictors(), num_comp = 4, id = "pca") %>%
  prep()

# KSSL PC space

mir.pca.scores.train <- juice(mir.pca.model) %>%
  rename_at(vars(starts_with("PC")), ~paste0("PC", as.numeric(gsub("PC", "", .))))

p.mir.scores.pc1.pc2 <- mir.pca.scores.train %>%
  ggplot(aes(x = PC1, y = PC2, color = code)) +
  geom_point(size = 0.25, alpha = 0.25) +
  labs(x = "PC1", y = "PC2", color = "") +
  theme_light() +
  theme(legend.position = "bottom")

# # Loadings
#
# mir.pca.loadings.train <- tidy(mir.pca.model, id = "pca", type = "coef") %>%
#   select(-id) %>%
#   filter(component %in% names(mir.pca.scores.train)) %>%
#   pivot_wider(values_from = "value", names_from = "component")
#
# p.mir.loading <- mir.pca.loadings.train %>%
#   pivot_longer(-terms, names_to = "PC", values_to = "loading") %>%
#   ggplot(aes(x = as.numeric(terms), y = loading, group = PC)) +
#   geom_line(size = 0.5) +
#   facet_wrap(~PC, ncol = 1) +
#   labs(x = bquote("Wavenumber"~cm^-1), y = "PCA loading",
#        title = "Training loadings") +
#   scale_x_continuous(breaks = c(600, 1200, 1800, 2400, 3000, 3600, 4000)) +
#   theme_light()

# Explained variance

mir.pca.variance.train <- tidy(mir.pca.model, id = "pca", type = "variance") %>%
  select(-id)

mir.pca.xve <- mir.pca.variance.train %>%
  filter(terms == "percent variance") %>%
  filter(component <= 4) %>%
  mutate(value = round(value, 2)) %>%
  pull(value)

# Project other datasets onto KSSL PC space

mir.pca.scores.test <- bake(mir.pca.model, new_data = mir.test.spectra) %>%
  rename_at(vars(starts_with("PC")), ~paste0("PC", as.numeric(gsub("PC", "", .)))) %>%
  select(-all_of(id.columns)) %>%
  bind_cols({mir.test.spectra %>%
      select(all_of(id.columns))}, .)

# Colors according to codes. KSSL must be black
unique(ossl.mir$code)

p.mir.scores.projected.pc1.pc2 <- p.mir.scores.pc1.pc2 +
  geom_point(data = mir.pca.scores.test,
             aes(x = PC1, y = PC2, color = code), size = 0.50, alpha = 0.25) +
  scale_color_manual(values = c("salmon", "orange", "red",
                                "blue", "yellow", "black",
                                "green", "purple", "lightblue")) +
  xlim(-100,100) + ylim(-100,100) +
  labs(x = paste0("PC1 (", mir.pca.xve[1], "%)"),
       y = paste0("PC2 (", mir.pca.xve[2], "%)")) +
  theme_light() +
  theme(legend.position = "bottom")

p.mir.scores.projected.pc1.pc2

ggsave(paste0(dir.figures, paste0("plot_pca_scores_mir_ossl.png")),
       p.mir.scores.projected.pc1.pc2, dpi = 300, width = 8, height = 6,
       units = "in", scale = 0.75)

# ## Inspect
# library(plotly)
# ggplotly(p.mir.scores.projected.pc1.pc2)

###################
##### Summary #####
###################

ossl <- qread("/mnt/soilspec4gg/ossl/ossl_import/ossl_all_L1_v1.2.qs")
neospectra <- qread("/mnt/soilspec4gg/ossl/dataset/Neospectra/ossl/neospectra_nir_v1.2.qs")

neospectra <- neospectra %>%
  select(id.sample_local_c, starts_with("scan_nir")) %>%
  group_by(id.sample_local_c) %>%
  summarise_all(mean)

ossl <- ossl %>%
  mutate(temp_id = gsub("XS|XN", "", id.scan_local_c)) %>%
  left_join(neospectra, by = c("temp_id" = "id.sample_local_c")) %>%
  select(-temp_id)

## Overview and preparation
ossl %>%
  select(scan_mir.1500_abs, scan_visnir.1500_ref, scan_nir.1500_ref) %>%
  summarise_all(~sum(!is.na(.)))

## Soil lab level 1
ossl.soillab <- read_csv("./out/ossl_level0_to_level1_soillab_harmonization.csv")

soil.properties <- ossl.soillab %>%
  distinct(ossl_name_level1) %>%
  pull(ossl_name_level1)

ossl.count <- ossl %>%
  select(dataset.code_ascii_txt, all_of(soil.properties), scan_mir.1500_abs,
         scan_visnir.1500_ref, scan_nir.1500_ref)

## Datasets
datasets <- ossl.count %>%
  distinct(dataset.code_ascii_txt) %>%
  pull(dataset.code_ascii_txt) %>%
  c("OSSL")

## Modeling combinations
modeling.combinations <- tibble(soil_property = soil.properties) %>%
  crossing(dataset = datasets) %>%
  crossing(tibble(spectra = c("scan_mir.1500_abs",
                              "scan_visnir.1500_ref",
                              "scan_nir.1500_ref")))

modeling.combinations

## Count

f_count <- function(i) {

  isoil.property <- modeling.combinations[[i,"soil_property"]]
  idataset <- modeling.combinations[[i,"dataset"]]
  ispectra <- modeling.combinations[[i,"spectra"]]

  if(idataset == "OSSL") {

    ossl.count %>%
      filter(!is.na(!!as.name(isoil.property))) %>%
      filter(!is.na(!!as.name(ispectra))) %>%
      nrow()

  } else {

    ossl.count %>%
        filter(dataset.code_ascii_txt == idataset) %>%
        filter(!is.na(!!as.name(isoil.property))) %>%
        filter(!is.na(!!as.name(ispectra))) %>%
        nrow()

  }

  # cat(paste0("Run ", i, "/", nrow(modeling.combinations), "\n"))

}

## Applying f_count with parallelization

doFuture::registerDoFuture()
future::plan("multisession")
options(future.globals.maxSize = 1000 * 1024^2)

count.list <- foreach(i = 1:nrow(modeling.combinations),
                      .combine = c) %dopar% {
  f_count(i)
}

## Exporting results
final.counts <- modeling.combinations %>%
  mutate(count = count.list) %>%
  mutate(spectra = recode(spectra,
                          "scan_mir.1500_abs" = "n_mir",
                          "scan_visnir.1500_ref" = "n_visnir",
                          "scan_nir.1500_ref" = "n_neospectra")) %>%
  pivot_wider(names_from = "spectra", values_from = "count")

write_csv(final.counts, "./out/tab_dataset_count.csv")
