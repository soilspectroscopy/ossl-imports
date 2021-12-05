
[![DOI](https://zenodo.org/badge/doi/10.5281/zenodo.5759693.svg)](https://doi.org/10.5281/zenodo.5759693)

# Import of Soil Spectral Libraries

[<img src="./img/soilspec4gg-logo_fc.png" alt="SoilSpec4GG logo" width="250"/>](https://soilspectroscopy.org/)

A repository for all data import development work for the [Soil Spectroscopy for Global
Good](https://soilspectroscopy.org) project.

Dataset import steps:

- Add dataset following the [project codes](https://soilspectroscopy.github.io/ossl-manual/database.html) to the `/dataset/` folder;
- Document import steps / produce four standard tables, write outputs to `/ossl` folder;
- Test dataset properties by plotting distributions, detect possible artifacts (see an [example](https://soilspectroscopy.github.io/ossl-manual/database.html#oc_usda.calc_wpct));
- After quality-control, all data is imported / bind to the global OSSL DB;
- Script `test_bind.R` contains all steps used to produce the final output;

For more advanced uses of the soil spectral libraries **we advise to contact the original data producers** 
especially to get help with using, extending and improving the original SSL data. Note: we **do NOT 
provide support with issues that my arise with the original soil spectral libraries**.

Other tools and repositories of interest:

- OSSL documentation: <https://soilspectroscopy.github.io/ossl-manual/>;
- OSSL Explorer: <https://explorer.soilspectroscopy.org>;
- OSSL Engine: <https://engine.soilspectroscopy.org>;
- Model fitting repository: <https://github.com/soilspectroscopy/ossl-models>;
