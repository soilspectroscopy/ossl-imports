# Open Soil Spectral Library (OSSL) — v1.3

This record archives release v1.3 of the Open Soil Spectral Library (OSSL). In earlier versions the data came as one merged database. In v1.3 each source dataset is distributed separately.

## Contents

- `OSSL_v1.3_<DATASET>.zip`: one archive per source dataset. Each archive contains the harmonized tables for that dataset, in both CSV (`.csv.gz`) and Parquet (`.parquet`):
  - `ossl_soilsite_v1.3`: site and sampling information
  - `ossl_soillab_v1.3`: soil laboratory data
  - `ossl_mir_v1.3`, `ossl_visnir_v1.3`, `ossl_nir_v1.3`: spectra, where available for that dataset
- `manifest.csv`: inventory of every file in the archives, with checksums
- `README.md`: this file

The archived files are identical to the v1.3 files served from the OSSL public bucket.

## Documentation

All documentation is maintained in the OSSL manual:

**https://docs.soilspectroscopy.org**

The manual covers the dataset catalog (descriptions, original producers, licenses, and references for each dataset), the harmonized variable definitions, the spectral formats, and how to access and use the data.

## Attribution

The source datasets belong to their original producers. When you use a dataset, please cite this record **and** the original source listed for it in the OSSL manual. For advanced use of a specific dataset, we recommend contacting its original producer.

## Funding

Soil Spectroscopy for the Global Good (SS4GG) was funded by the USDA NIFA Food and Agriculture Cyberinformatics Tools Program (Award #2020-67021-32467) and is currently maintained with limited institutional support and indirect funding.
