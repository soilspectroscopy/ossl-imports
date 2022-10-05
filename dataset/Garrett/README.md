Dataset import: Garrett et al. (2022)
================
Jose Lucas Safanelli (<jsafanelli@woodwellclimate.org>) and Jonathan
Sanderman (<jsanderman@woodwellclimate.org>)
05 October, 2022



-   [The Garrett et al. (2022) Soil Spectral
    Library](#the-garrett-et-al-2022-soil-spectral-library)
-   [Data import](#data-import)
    -   [Soil site information](#soil-site-information)
-   [References](#references)

[<img src="../../img/soilspec4gg-logo_fc.png" alt="SoilSpec4GG logo" width="250"/>](https://soilspectroscopy.org/)

[<img alt="Creative Commons License" style="border-width:0" src="https://i.creativecommons.org/l/by-sa/4.0/88x31.png"/>](http://creativecommons.org/licenses/by-sa/4.0/)

This work is licensed under a [Creative Commons Attribution-ShareAlike
4.0 International
License](http://creativecommons.org/licenses/by-sa/4.0/).

## The Garrett et al. (2022) Soil Spectral Library

Part of: <https://github.com/soilspectroscopy>  
Project: [Soil Spectroscopy for Global
Good](https://soilspectroscopy.org)  
Last update: 2022-10-05  
Dataset:
[GARRETT.SSL](https://soilspectroscopy.github.io/ossl-manual/soil-spectroscopy-tools-and-users.html#garrett.ssl)

Mid-Infrared Spectra (MIRS) of 186 soil samples described in [Garrett et
al.](#ref-Garrett2022) ([2022](#ref-Garrett2022)).

Directory/folder path:

``` r
dir = "/mnt/soilspec4gg/ossl/dataset/Garrett/"
```

## Data import

The dataset is publicly shared at Figshare
<https://doi.org/10.6084/m9.figshare.20506587.v2>.

``` r
# Checking shared files
list.files(dir)
```

    ##  [1] "FR380_chemical.xlsx"        "FR380_MIR spectra"         
    ##  [3] "FR380_MIR spectra_csv"      "FR380_MIR spectra_csv.zip" 
    ##  [5] "FR380_MIR spectra.zip"      "FR380_particlesize.xlsx"   
    ##  [7] "FR380_physical.xlsx"        "FR380_sitedescription.xlsx"
    ##  [9] "FR380_Soil Profile.zip"     "FR380_soilprofile.xlsx"    
    ## [11] "ossl_soilsite_v1.rds"       "SoilProfile"

``` r
# Checking FR380_sitedescription
excel_sheets(paste0(dir, "/FR380_sitedescription.xlsx"))
```

    ## [1] "FR380_site description"

``` r
garrett.sitedescription <- readxl::read_xlsx(paste0(dir, "/FR380_sitedescription.xlsx"), sheet = "FR380_site description")
names(garrett.sitedescription)
```

    ##  [1] "LCR_Soil Profile ID"                                                   
    ##  [2] "Trial ID"                                                              
    ##  [3] "Date observed"                                                         
    ##  [4] "Latitude (°)"                                                          
    ##  [5] "Longitude (°)"                                                         
    ##  [6] "Altitude (m)"                                                          
    ##  [7] "Slope (°)"                                                             
    ##  [8] "Aspect (°)"                                                            
    ##  [9] "Provider of soil profile description"                                  
    ## [10] "Soil series"                                                           
    ## [11] "Soil type"                                                             
    ## [12] "NZSC Order"                                                            
    ## [13] "NZSC Group"                                                            
    ## [14] "NZSC Subgroup"                                                         
    ## [15] "NZSC soil form M1"                                                     
    ## [16] "NZSC soil form M2"                                                     
    ## [17] "NZSC soil form M3"                                                     
    ## [18] "NZSC soil form M4"                                                     
    ## [19] "Profile shape"                                                         
    ## [20] "Surface outcrops (%)"                                                  
    ## [21] "Surface boulders (%)"                                                  
    ## [22] "Soil profile drainage"                                                 
    ## [23] "Land management prior to FR380 trial planting"                         
    ## [24] "Forest rotation number prior to FR380 trial planting"                  
    ## [25] "Planted tree species prior to FR380 trial planting or pasture land use"
    ## [26] "Forest rotation number of the FR380 trial"                             
    ## [27] "Soil parent material"                                                  
    ## [28] "Geological substrate"                                                  
    ## [29] "Top soil depth (m)"                                                    
    ## [30] "Total rooting depth (m)"                                               
    ## [31] "Limiting horizon - nature and depth (m)"                               
    ## [32] "Profile exposed in"

``` r
# Checking FR380_soilprofile
# excel_sheets(paste0(dir, "/FR380_soilprofile.xlsx"))
garrett.soilprofile <- readxl::read_xlsx(paste0(dir, "/FR380_soilprofile.xlsx"), sheet = "FR380_soil profile")
names(garrett.soilprofile)
```

    ##  [1] "Trial ID"                                      
    ##  [2] "LCR_Soil profile ID"                           
    ##  [3] "LCR_Horizon number"                            
    ##  [4] "Horizon notation"                              
    ##  [5] "Horizon top (cm)"                              
    ##  [6] "Horizon base (cm)"                             
    ##  [7] "Soil water description"                        
    ##  [8] "Colour code"                                   
    ##  [9] "Colour description"                            
    ## [10] "Mottles 1 abundance (%)"                       
    ## [11] "Mottles 1 abundance description"               
    ## [12] "Mottles 1 size (mm)"                           
    ## [13] "Mottles 1 size class"                          
    ## [14] "Mottles 1 contrast"                            
    ## [15] "Mottles 1 colour code"                         
    ## [16] "Mottles 2 abundance (%)"                       
    ## [17] "Mottles 2 abundance description"               
    ## [18] "Mottles 2 size (mm)"                           
    ## [19] "Mottles 2 size class"                          
    ## [20] "Mottles 2 contrast"                            
    ## [21] "Mottles 2 colour code"                         
    ## [22] "Texture class"                                 
    ## [23] "Texture sand class"                            
    ## [24] "Texture organic matter"                        
    ## [25] "Gravel <200mm abundance (%)"                   
    ## [26] "Gravel <200mm abundance class"                 
    ## [27] "Gravel <200mm abundance size (mm)"             
    ## [28] "Gravel <200mm abundance size class"            
    ## [29] "Gravel <200mm weathering"                      
    ## [30] "Gravel <200mm rounding"                        
    ## [31] "Gravel <200mm rock"                            
    ## [32] "Boulders >200mm abundance (%)"                 
    ## [33] "Boulders >200mm abundance class"               
    ## [34] "Boulders >200mm size (mm)"                     
    ## [35] "Boulders >200mm size class"                    
    ## [36] "Boulders >200mm weathering"                    
    ## [37] "Boulders >200mm roundness"                     
    ## [38] "Boulders >200mm rock"                          
    ## [39] "Parent material - determination"               
    ## [40] "Parent material - partile size"                
    ## [41] "Parent material - orgin"                       
    ## [42] "Parent material - alteration"                  
    ## [43] "Parent material - induration"                  
    ## [44] "Soil strength"                                 
    ## [45] "Ped strength"                                  
    ## [46] "Failure"                                       
    ## [47] "Fluidity"                                      
    ## [48] "Penetration resistence description"            
    ## [49] "Packing description"                           
    ## [50] "Particle packing description"                  
    ## [51] "Sensitivity"                                   
    ## [52] "Induration description"                        
    ## [53] "Plasticity"                                    
    ## [54] "Stickyness"                                    
    ## [55] "Pedality type"                                 
    ## [56] "Apedal materials"                              
    ## [57] "Pedality degree"                               
    ## [58] "Primary macrofabric - Abundance description"   
    ## [59] "Primary macrofabric - Size description"        
    ## [60] "Primary macrofabric - Shape"                   
    ## [61] "Link"                                          
    ## [62] "Secondary macrofabric - Abundance description" 
    ## [63] "Secondary macrofabric - Size description"      
    ## [64] "Secondary macrofabric - Shape"                 
    ## [65] "Voids abundance (%)"                           
    ## [66] "Voids size (mm)"                               
    ## [67] "Voids ture"                                    
    ## [68] "Concentration abundance (%)"                   
    ## [69] "Concentration abundance description"           
    ## [70] "Concentration size (mm)"                       
    ## [71] "Concentration colour code"                     
    ## [72] "Concentration type"                            
    ## [73] "Pan type"                                      
    ## [74] "Surface features - coats kind"                 
    ## [75] "Surface features - coats location"             
    ## [76] "Surface features - coats abundance (%)"        
    ## [77] "Surface features - coats abundance description"
    ## [78] "Surface features - coats continuity"           
    ## [79] "Surface features - coats distinction"          
    ## [80] "Surface features - coat thickness (mm)"        
    ## [81] "Surface features - coats thickness description"
    ## [82] "Surface features - coats roughness"            
    ## [83] "Surface features - coats colour code"          
    ## [84] "Surface features - coats colour description"   
    ## [85] "Root 1 abundance description"                  
    ## [86] "Root 1 size (mm)"                              
    ## [87] "Root 1 size description"                       
    ## [88] "Root 1 location"                               
    ## [89] "Root 1 type"                                   
    ## [90] "Root 2 abundance description"                  
    ## [91] "Root 2 size (mm)"                              
    ## [92] "Root 2 size description"                       
    ## [93] "Root 2 location"                               
    ## [94] "Root 2 type"                                   
    ## [95] "Horizon boundary distinction"                  
    ## [96] "Horizon boundary shape"

``` r
# Checking FR380_physical
excel_sheets(paste0(dir, "/FR380_physical.xlsx"))
```

    ## [1] "FR380_Physical"  "Data dictionary"

``` r
garrett.physical <- readxl::read_xlsx(paste0(dir, "/FR380_physical.xlsx"), sheet = "FR380_Physical")
# View(read_xlsx(paste0(dir, "/FR380_physical.xlsx"), sheet = "Data dictionary"))
names(garrett.physical)
```

    ##  [1] "Trial ID"                                                            
    ##  [2] "Location of sample"                                                  
    ##  [3] "Sample Method"                                                       
    ##  [4] "Sample plots 'Disturbed' or 'Undisturbed'"                           
    ##  [5] "Horizon notation"                                                    
    ##  [6] "Horizon top (cm)"                                                    
    ##  [7] "Horizon base (cm)"                                                   
    ##  [8] "LCR_Soil profile ID"                                                 
    ##  [9] "LCR_Lab letter"                                                      
    ## [10] "LCR_Horizon number"                                                  
    ## [11] "Lab Code"                                                            
    ## [12] "Particle density (g/cm3)"                                            
    ## [13] "Bulk density (g/cm3)"                                                
    ## [14] "Porosity (%)"                                                        
    ## [15] "Macro-porosity (%)"                                                  
    ## [16] "Air capacity (%)"                                                    
    ## [17] "Void Ratio"                                                          
    ## [18] "Field capacity (%)"                                                  
    ## [19] "Water content at saturation (calculation) (%w/w)"                    
    ## [20] "Water content at 5 kPa (%w/w)"                                       
    ## [21] "Water content at 10 kPa (%w/w)"                                      
    ## [22] "Water content at 100 kPa (%w/w)"                                     
    ## [23] "Water content at 1500 kPa (%w/w)"                                    
    ## [24] "Water content at saturation (calculation) (%v/v)"                    
    ## [25] "Water content at 5 kPa (%v/v)"                                       
    ## [26] "Water content at 10 kPa (%v/v)"                                      
    ## [27] "Water content at 100 kPa (%v/v)"                                     
    ## [28] "Water content at 1500 kPa (%v/v)"                                    
    ## [29] "Penetration Resistance at 10 kPa, 3-6 cm at FC, Mean of 2 reps (MPa)"
    ## [30] "Water content at field moisture (%w/w)"                              
    ## [31] "Water content at field moisture (%v/v)"                              
    ## [32] "RAW \r\n(10-100 kPa)"                                                
    ## [33] "TAW\r\n(10-1500 kPa)"                                                
    ## [34] "Pedology stone content (%)"                                          
    ## [35] "RAW (10-100 kPa) (stone corr.) (%)"                                  
    ## [36] "TAW (100-1500 kPa) (stone corr.) (%)"

``` r
# Checking FR380_chemical
excel_sheets(paste0(dir, "/FR380_chemical.xlsx"))
```

    ## [1] "FR380_Chemical"  "Data dictionary"

``` r
garrett.chemical <- readxl::read_xlsx(paste0(dir, "/FR380_chemical.xlsx"), sheet = "FR380_Chemical", skip = 1)
# View(read_xlsx(paste0(dir, "/FR380_chemical.xlsx"), sheet = "Data dictionary"))
names(garrett.chemical)
```

    ##  [1] "Trial ID"                              
    ##  [2] "Sampling Date"                         
    ##  [3] "Sample Method"                         
    ##  [4] "Horizon top (cm)"                      
    ##  [5] "Horizon base (cm)"                     
    ##  [6] "0-10cm sample disturbed or undistrubed"
    ##  [7] "Comment"                               
    ##  [8] "LCR_Sample ID"                         
    ##  [9] "LCR_Soil profile ID"                   
    ## [10] "LCR_Lab letter"                        
    ## [11] "LCR_Horizon number"                    
    ## [12] "LCR_pH [H2O]"                          
    ## [13] "LCR_Total Carbon (%)"                  
    ## [14] "LCR_Total Nitrogen (%)"                
    ## [15] "LCR_Carbon/Nitrogen"                   
    ## [16] "LCR_P Olsen Available (ug/g)"          
    ## [17] "LCR_P Bray Available (ug/g)"           
    ## [18] "LCR_P inorganic (mg%)"                 
    ## [19] "LCR_P organic (mg%)"                   
    ## [20] "LCR_P Total (mg%)"                     
    ## [21] "LCR_P retention (%)"                   
    ## [22] "LCR_CEC (me.%)"                        
    ## [23] "LCR_Sum bases (me.%)"                  
    ## [24] "LCR_Base saturation (%)"               
    ## [25] "LCR_Exchange Ca (me.%)"                
    ## [26] "LCR_Exchange Mg (me.%)"                
    ## [27] "LCR_Exchange K (me.%)"                 
    ## [28] "LCR_Exchange Na (me.%)"                
    ## [29] "Scion_Sample ID"                       
    ## [30] "Scion_pH [H2O]"                        
    ## [31] "Scion_Bray P (mg/kg) seq 1"            
    ## [32] "Scion_Bray P (mg/kg) seq 2"            
    ## [33] "Scion_Bray P (mg/kg) seq 3"            
    ## [34] "Scion_Mehlich 3 B (mg/kg)"             
    ## [35] "Scion_Mehlich 3 Al (mg/kg)"            
    ## [36] "Scion_Mehlich 3 Na (mg/kg)"            
    ## [37] "Scion_Mehlich 3 Mg (mg/kg)"            
    ## [38] "Scion_Mehlich 3 P (mg/kg)"             
    ## [39] "Scion_Mehlich 3 K (mg/kg)"             
    ## [40] "Scion_Mehlich 3 Ca (mg/kg)"            
    ## [41] "Scion_Mehlich 3 Mn (mg/kg)"            
    ## [42] "Scion_Mehlich 3 Fe (mg/kg)"            
    ## [43] "Scion_Mehlich 3 Cu (mg/kg)"            
    ## [44] "Scion_Mehlich 3 Zn (mg/kg)"            
    ## [45] "Lab 3_Sulphate S (mg/kg)"              
    ## [46] "Lab 4_Total B (mg/kg)"                 
    ## [47] "Lab 4_Total Na (mg/kg)"                
    ## [48] "Lab 4_Total Mg (mg/kg)"                
    ## [49] "Lab 4_Total Al (mg/kg)"                
    ## [50] "Lab 4_Total P (mg/kg)"                 
    ## [51] "Lab 4_Total S (mg/kg)"                 
    ## [52] "Lab 4_Total K (mg/kg)"                 
    ## [53] "Lab 4_Total Ca (mg/kg)"                
    ## [54] "Lab 4_Total V (mg/kg)"                 
    ## [55] "Lab 4_Total Cr (mg/kg)"                
    ## [56] "Lab 4_Total Mn (mg/kg)"                
    ## [57] "Lab 4_Total Fe (mg/kg"                 
    ## [58] "Lab 4_Total Co (mg/kg)"                
    ## [59] "Lab 4_Total Ni (mg/kg)"                
    ## [60] "Lab 4_Total Cu (mg/kg)"                
    ## [61] "Lab 4_Total Zn (mg/kg)"                
    ## [62] "Lab 4_Total As (mg/kg)"                
    ## [63] "Lab 4_Total Se (mg/kg)"                
    ## [64] "Lab 4_Total Sr (mg/kg)"                
    ## [65] "Lab 4_Total Cd (mg/kg)"                
    ## [66] "Lab 4_Total Ba (mg/kg)"                
    ## [67] "Lab 4_Total Tl (mg/kg)"                
    ## [68] "Lab 4_Total Pb (mg/kg)"                
    ## [69] "Lab 4_Total U (mg/kg)"

``` r
# Checking FR380_particlesize
excel_sheets(paste0(dir, "/FR380_particlesize.xlsx"))
```

    ## [1] "FR380_Particle size" "Data dictionary"

``` r
garrett.particlesize <- readxl::read_xlsx(paste0(dir, "/FR380_particlesize.xlsx"), sheet = "FR380_Particle size", skip = 0)
# View(read_xlsx(paste0(dir, "/FR380_particlesize.xlsx"), sheet = "Data dictionary"))
names(garrett.particlesize)
```

    ##  [1] "Trial ID"            "LCR_Soil profile ID" "LCR_Lab letter"     
    ##  [4] "LCR_Horizon number"  "Coarse sand (%)"     "Medium sand (%)"    
    ##  [7] "Fine sand (%)"       "Sand (%)"            "Silt (%)"           
    ## [10] "Clay (%)"

``` r
# Spectral measurements

scans.csv <- list.files(paste0(dir, "/FR380_MIR spectra_csv"), full.names = TRUE)
scans.names <- list.files(paste0(dir, "/FR380_MIR spectra_csv"), full.names = FALSE)

# # Spectra is stored in long format without header, first column wavenumber, second column absorbance
# mir.test <- readr::read_csv(scans.csv[1], show_col_types = FALSE, col_names = FALSE) %>%
#   setNames(c("wavenumber", "absorbance"))
# ggplot(mir.test) + geom_line(aes(x = wavenumber, y = absorbance, group = 1))

mir.allspectra <- purrr::map_dfr(.x = scans.csv, .f = readr::read_csv, .id = "source",
                                 show_col_types = FALSE, col_names = FALSE) # Additional arguments of read_csv

mir.allspectra <- mir.allspectra %>%
  tidyr::pivot_wider(names_from = "X1", values_from = "X2") %>%
  dplyr::mutate(id = scans.names, .before = 1) %>%
  dplyr::mutate(id = gsub(".csv", "", id))
```

Spectral data filenames follow Scion\_Sample ID present in chemical
data, but there are other id columns from LCR and site ids that are
necessary for binding with other tables (like physical). Anyway,
Scion\_Sample ID will be used as `id.layer_local_c` in the OSSL.

``` r
garrett.ids <- garrett.chemical %>%
  dplyr::select(`Scion_Sample ID`, `Trial ID`,
                `LCR_Sample ID`, `LCR_Soil profile ID`,
                `LCR_Lab letter`, `LCR_Horizon number`,
                `Horizon top (cm)`, `Horizon base (cm)`,) %>%
  dplyr::rename(id.layer_local_c = `Scion_Sample ID`,
                id.user.site_ascii_c = `Trial ID`,
                layer.upper.depth_usda_cm = `Horizon top (cm)`,
                layer.lower.depth_usda_cm = `Horizon base (cm)`) %>%
  dplyr::filter(!is.na(id.layer_local_c)) %>%
  dplyr::mutate(id.user.site_ascii_c = gsub("\\s", "", id.user.site_ascii_c))

# Checking number of spectral replicates 
mir.allspectra %>%
  tidyr::separate(id, into = c("id", "replicate"), sep = "-") %>%
  dplyr::group_by(id) %>%
  dplyr::summarise(n = n()) %>%
  dplyr::group_by(n) %>%
  dplyr::summarise(count = n())
```

    ## # A tibble: 2 × 2
    ##       n count
    ##   <int> <int>
    ## 1     3   144
    ## 2     4    40

``` r
# Checking number of unique spectral samples
mir.allspectra %>%
  tidyr::separate(id, into = c("id", "replicate"), sep = "-") %>%
  dplyr::group_by(id) %>%
  dplyr::summarise(n = n()) %>%
  dplyr::ungroup() %>%
  nrow()
```

    ## [1] 184

``` r
# Same number of samples in chemical data
garrett.ids %>%
  dplyr::summarise(count = n())
```

    ## # A tibble: 1 × 1
    ##   count
    ##   <int>
    ## 1   184

``` r
# Are there duplicates? No
garrett.ids %>%
  dplyr::distinct(id.layer_local_c) %>%
  dplyr::summarise(count = n())
```

    ## # A tibble: 1 × 1
    ##   count
    ##   <int>
    ## 1   184

### Soil site information

``` r
# Formatting to OSSL standard
garrett.soilsite <- garrett.sitedescription %>%
  dplyr::select(`Trial ID`, `Date observed`, `Latitude (°)`, `Longitude (°)`) %>%
  dplyr::rename(longitude_wgs84_dd = `Longitude (°)`, latitude_wgs84_dd = `Latitude (°)`,
                id.user.site_ascii_c = `Trial ID`) %>%
  dplyr::mutate(id.user.site_ascii_c = gsub("\\s", "", id.user.site_ascii_c)) %>%
  dplyr::mutate(id.dataset.site_ascii_c = id.user.site_ascii_c,
                `Date observed` = lubridate::ymd(`Date observed`)) %>%
  dplyr::mutate(observation.date.begin_iso.8601_yyyy.mm.dd = stringr::str_c(lubridate::year(`Date observed`),
                                                                            lubridate::month(`Date observed`),
                                                                            lubridate::day(`Date observed`),
                                                                            sep = "."),
                observation.date.end_iso.8601_yyyy.mm.dd = stringr::str_c(lubridate::year(`Date observed`),
                                                                            lubridate::month(`Date observed`),
                                                                            lubridate::day(`Date observed`),
                                                                            sep = ".")) %>%
  dplyr::select(id.user.site_ascii_c, id.dataset.site_ascii_c,
                longitude_wgs84_dd, latitude_wgs84_dd,
                observation.date.begin_iso.8601_yyyy.mm.dd,
                observation.date.end_iso.8601_yyyy.mm.dd) %>%
  dplyr::left_join({garrett.ids %>%
      dplyr::select(-contains("LCR"))}, ., by = "id.user.site_ascii_c") %>%
  dplyr::mutate(id.layer_uuid_c = openssl::md5(id.layer_local_c), # Adding missing metadata
                id.location_olc_c = olctools::encode_olc(latitude_wgs84_dd, longitude_wgs84_dd, 10),
                observation.ogc.schema.title_ogc_txt = 'Open Soil Spectroscopy Library',
                observation.ogc.schema_idn_url = 'https://soilspectroscopy.github.io',
                location.address_utf8_txt = "New Zealand",
                location.country_iso.3166_c = "NZL",
                location.method_any_c = "survey",
                location.error_any_m = 1111, # Only two decimal places in lat long
                surveyor.title_utf8_txt = "Loretta Garrett",
                surveyor.contact_ietf_email = "loretta.garrett@scionresearch.com",
                surveyor.address_utf8_txt = 'Scion, Private Bag 3020, Rotorua 3046, New Zealand',
                dataset.title_utf8_txt = 'Garrett et al. (2022)',
                dataset.owner_utf8_txt = 'Garrett et al. (2022)',
                dataset.code_ascii_txt = 'GARRETT.SSL',
                dataset.address_idn_url = 'https://doi.org/10.6084/m9.figshare.20506587.v2',
                dataset.license.title_ascii_txt = 'CC-BY 4.0',
                dataset.license.address_idn_url = 'https://creativecommons.org/licenses/by/4.0/legalcode',
                dataset.doi_idf_c = 'https://doi.org/10.6084/m9.figshare.20506587.v2',
                dataset.contact.name_utf8_txt = "Loretta Garrett",
                dataset.contact.email_ietf_email = "loretta.garrett@scionresearch.com",
                id.project_ascii_c = "GARRETT") %>%
  dplyr::select(id.layer_uuid_c, # Following the sequence from ossl-manual
                id.layer_local_c,
                id.location_olc_c,
                observation.ogc.schema.title_ogc_txt,
                observation.ogc.schema_idn_url,
                observation.date.begin_iso.8601_yyyy.mm.dd,
                observation.date.end_iso.8601_yyyy.mm.dd,
                location.address_utf8_txt,
                location.country_iso.3166_c,
                location.method_any_c,
                surveyor.title_utf8_txt,
                surveyor.contact_ietf_email,
                surveyor.address_utf8_txt,
                longitude_wgs84_dd,
                latitude_wgs84_dd,
                location.error_any_m,
                dataset.title_utf8_txt,
                dataset.owner_utf8_txt,
                dataset.code_ascii_txt,
                dataset.address_idn_url,
                dataset.license.title_ascii_txt,
                dataset.license.address_idn_url,
                dataset.doi_idf_c,
                dataset.contact.name_utf8_txt,
                dataset.contact.email_ietf_email,
                id.dataset.site_ascii_c,
                id.user.site_ascii_c,
                id.project_ascii_c)
```

Exporting soilsite data

``` r
soilsite.rds = paste0(dir, "/ossl_soilsite_v1.rds")
saveRDS(garrett.soilsite, soilsite.rds)
```

<!-- ### Soil lab information -->
<!-- ```{r, warning=FALSE} -->
<!-- # names(garrett.info) -->
<!-- in.names <- c("BD_bulk", "BD_fine", -->
<!--               "TN", "TC", "SOC", -->
<!--               "pH_CaCl2_site", "EC_CaCl2_site", "eff_CEC_site", -->
<!--               "clay_site", "silt_site", "sand_site") -->
<!-- out.names <- c("bd.core_iso.11272.2017_gcm3", "bd.od_usda.3b2_gcm3", -->
<!--                "n.tot_iso.13878.1998_wpct", "c.tot_iso.10694.1995_wpct", "oc_iso.10694.1995_wpct", -->
<!--                "ph.cacl2_usda.4c1_index", "ec.w_usda.4f1_dsm", "ecec_usda.4b4_cmolkg", -->
<!--                "clay.tot_iso.11277.2020_wpct", "silt.tot_iso.11277.2020_wpct", "sand.tot_iso.11277.2020_wpct") -->
<!-- garrett.soillab <- garrett.info %>% # Spectra ID is the merge of EUP, sample_point, and increment -->
<!--   dplyr::mutate(id.layer_local_c = paste0(EUP, ".", sample_point, "_", increment), .before = 1) %>% -->
<!--   tidyr::separate(increment, into = c("layer.upper.depth_usda_cm", "layer.lower.depth_usda_cm"), sep = "-") %>% -->
<!--   dplyr::mutate(layer.upper.depth_usda_cm = as.numeric(layer.upper.depth_usda_cm), -->
<!--                 layer.lower.depth_usda_cm = as.numeric(layer.lower.depth_usda_cm)) %>% -->
<!--   dplyr::rename_with(~out.names, all_of(in.names)) %>% -->
<!--   dplyr::select(id.layer_local_c, layer.upper.depth_usda_cm, layer.lower.depth_usda_cm, all_of(out.names)) %>% -->
<!--   dplyr::mutate_at(vars(-id.layer_local_c), as.numeric) %>% -->
<!--   dplyr::mutate(id.layer_uuid_c = openssl::md5(id.layer_local_c), .before = 1) -->
<!-- ``` -->
<!-- Exporting soillab data -->
<!-- ```{r} -->
<!-- soillab.rds = paste0(dir, "/ossl_soillab_v1.rds") -->
<!-- saveRDS(garrett.soillab, soillab.rds) -->
<!-- ``` -->
<!-- ### Mid-infrared spectroscopy data -->
<!-- Mid-infrared (MIR) soil spectroscopy raw data (<https://doi.org/10.5281/zenodo.6024831>). Samples have different spectral range, therefore two spectral sets were formatted and binded together. -->
<!-- Spec1: -->
<!-- ```{r} -->
<!-- # excel_sheets(paste0(dir, "/Schiedung_opusimport.xlsx"))  -->
<!-- garrett.spec1 <- read_xlsx(paste0(dir, "/Schiedung_opusimport.xlsx"), sheet = 1) -->
<!-- # garrett.spec1 %>% pull(ID) # ID is the merge of EUP, sample_point, and increment -->
<!-- # First column names -->
<!-- names(garrett.spec1[,1:10]) -->
<!-- # Removing filename column -->
<!-- garrett.spec1 <- garrett.spec1 %>% -->
<!--   dplyr::select(-filename) -->
<!-- # Checking spectral range and resolution -->
<!-- spectra <- garrett.spec1 %>% -->
<!--   dplyr::select(-all_of(c("ID"))) -->
<!-- old.spectral.range <- as.numeric(names(spectra)) -->
<!-- cat("Spectral range between", range(old.spectral.range)[1], "and", range(old.spectral.range)[2], "cm-1 \n") -->
<!-- cat("Spectral resolution is", old.spectral.range[2]-old.spectral.range[1], "cm-1 \n") -->
<!-- # Resampling to 600-4000 interval -->
<!-- new.spectral.range <- seq(4000, 600, by = -2) -->
<!-- new.spectra <- spectra %>% -->
<!--   prospectr::resample(wav = old.spectral.range, new.wav = new.spectral.range, interpol = "spline") %>% -->
<!--   tibble::as_tibble() -->
<!-- # Checking new range -->
<!-- cat("New spectral range between ", range(as.numeric(names(new.spectra))), "cm-1 \n") -->
<!-- # Preparing final spec 1 -->
<!-- soilmir1 <- garrett.spec1 %>% -->
<!--   dplyr::select(all_of(c("ID"))) %>% -->
<!--   dplyr::bind_cols(new.spectra) %>% -->
<!--   dplyr::select(all_of(c("ID")), all_of(rev(as.character(new.spectral.range)))) -->
<!-- ``` -->
<!-- Spec2: -->
<!-- ```{r} -->
<!-- # excel_sheets(paste0(dir, "/Schiedung_opusimport.xlsx"))  -->
<!-- garrett.spec2 <- read_xlsx(paste0(dir, "/Schiedung_opusimport.xlsx"), sheet = 2) -->
<!-- # garrett.spec2 %>% pull(ID) # ID is the merge of EUP, sample_point, and increment -->
<!-- # First column names -->
<!-- names(garrett.spec2[,1:10]) -->
<!-- # Removing filename column -->
<!-- garrett.spec2 <- garrett.spec2 %>% -->
<!--   dplyr::select(-filename) -->
<!-- # Checking spectral range and resolution -->
<!-- spectra <- garrett.spec2 %>% -->
<!--   dplyr::select(-all_of(c("ID"))) -->
<!-- old.spectral.range <- as.numeric(names(spectra)) -->
<!-- cat("Spectral range between", range(old.spectral.range)[1], "and", range(old.spectral.range)[2], "cm-1 \n") -->
<!-- cat("Spectral resolution is", old.spectral.range[2]-old.spectral.range[1], "cm-1 \n") -->
<!-- # Resampling to 600-4000 interval -->
<!-- new.spectral.range <- seq(4000, 600, by = -2) -->
<!-- new.spectra <- spectra %>% -->
<!--   prospectr::resample(wav = old.spectral.range, new.wav = new.spectral.range, interpol = "spline") %>% -->
<!--   tibble::as_tibble() -->
<!-- # Checking new range -->
<!-- cat("New spectral range between ", range(as.numeric(names(new.spectra))), "cm-1 \n") -->
<!-- # Preparing final spec 1 -->
<!-- soilmir2 <- garrett.spec2 %>% -->
<!--   dplyr::select(all_of(c("ID"))) %>% -->
<!--   dplyr::bind_cols(new.spectra) %>% -->
<!--   dplyr::select(all_of(c("ID")), all_of(rev(as.character(new.spectral.range)))) -->
<!-- ``` -->
<!-- Binding together and exporting: -->
<!-- ```{r} -->
<!-- garrett.mir <- bind_rows(soilmir1, soilmir2) %>% -->
<!--   dplyr::rename(id.layer_local_c = ID) %>% -->
<!--   dplyr::mutate(id.layer_local_c = gsub("0-12", "0-15", id.layer_local_c)) %>% -->
<!--   dplyr::mutate(id.layer_local_c = gsub("16-28", "15-30", id.layer_local_c)) %>% -->
<!--   dplyr::mutate(id.layer_local_c = gsub("32-44", "30-45", id.layer_local_c)) %>% -->
<!--   dplyr::mutate(id.layer_local_c = gsub("48-60", "45-60", id.layer_local_c)) %>% -->
<!--   dplyr::mutate(id.layer_uuid_c = openssl::md5(id.layer_local_c), .before = 1) -->
<!-- soilmir.rds = paste0(dir, "/ossl_mir_v1.rds") -->
<!-- saveRDS(garrett.mir, soilmir.rds) -->
<!-- ``` -->
<!-- ### Quality control -->
<!-- Checking IDs: -->
<!-- ```{r} -->
<!-- # Checking if soil site ids are unique -->
<!-- table(duplicated(garrett.soilsite$id.layer_uuid_c)) -->
<!-- # Checking if soilab ids are compatible -->
<!-- table(garrett.soilsite$id.layer_uuid_c %in% garrett.soillab$id.layer_uuid_c) -->
<!-- # Checking if mir ids are compatible. In this case there 30 samples missing spectra -->
<!-- table(garrett.soilsite$id.layer_local_c %in% garrett.mir$id.layer_local_c) -->
<!-- ``` -->
<!-- Plotting sites map: -->
<!-- ```{r map} -->
<!-- data("World") -->
<!-- points <- garrett.soilsite %>% -->
<!--    st_as_sf(coords = c('longitude_wgs84_dd', 'latitude_wgs84_dd'), crs = 4326) -->
<!-- tmap_mode("plot") -->
<!-- tm_shape(World) + -->
<!--   tm_polygons('#f0f0f0f0', border.alpha = 0.2) + -->
<!--   tm_shape(points) + -->
<!--   tm_dots() -->
<!-- ``` -->
<!-- Soil analytical data summary: -->
<!-- ```{r} -->
<!-- garrett.soillab %>% -->
<!--   skimr::skim() %>% -->
<!--   dplyr::select(-numeric.hist, -complete_rate) -->
<!-- ``` -->
<!-- Spectral visualization: -->
<!-- ```{r spec} -->
<!-- garrett.mir %>% -->
<!--   tidyr::pivot_longer(-all_of(c("id.layer_uuid_c", "id.layer_local_c")), names_to = "wavenumber", values_to = "absorbance") %>% -->
<!--   dplyr::mutate(wavenumber = as.numeric(wavenumber)) %>% -->
<!--   ggplot(aes(x = wavenumber, y = absorbance, group = id.layer_local_c)) + -->
<!--   geom_line(alpha = 0.1) + -->
<!--   scale_x_continuous(breaks = c(600, 1200, 1800, 2400, 3000, 3600, 4000)) + -->
<!--   labs(x = bquote("Wavenumber"~(cm^-1)), y = "Absorbance") + -->
<!--   theme_light() -->
<!-- ``` -->
<!-- ### Rendering report -->

Exporting to md/html for GitHub.

``` r
rmarkdown::render("README.Rmd")
```

## References

<div id="refs" class="references csl-bib-body hanging-indent"
line-spacing="2">

<div id="ref-Garrett2022" class="csl-entry">

Garrett, L. G., Sanderman, J., Palmer, D. J., Dean, F., Patel, S.,
Bridson, J. H., & Carlin, T. (2022). Mid-infrared spectroscopy for
planted forest soil and foliage nutrition predictions, new zealand case
study. *Trees, Forests and People*, *8*, 100280.
doi:[10.1016/j.tfp.2022.100280](https://doi.org/10.1016/j.tfp.2022.100280)

</div>

</div>
