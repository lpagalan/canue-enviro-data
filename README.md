# Introduction
This script compiles annual environmental data from the [Canadian Urban Environmental Health Research Consortium](https://canue.ca) (CANUE) and prepares them for linkage to other datasets. CANUE data are provided as annual CSV files, and this code merges the annual datasets into one. The compiled dataset allows merging to other data using 6-digit postal code and year as a merge key. Data are available through the [CANUE Data Portal](https://www.canuedata.ca).

# Data
The script processes the following datasets:

- Air Quality
  - [Nitrogen Dioxide](https://github.com/lpagalan/canue-enviro-data/blob/main/Data/Air%20Quality/NO2/CANUE_METADATA_NO2LUR_A_YY.pdf) (NO<sub>2</sub>)
  - [Ozone](https://github.com/lpagalan/canue-enviro-data/blob/main/Data/Air%20Quality/O3/CANUE_METADATA_O3CHG_A_YY.pdf) (O<sub>3</sub>)
  - Particulate Matter 2.5 micrometres and smaller (PM<sub>2.5</sub>)
- Greenness
  - Landsat Normalized Difference Vegetation Index (NDVI)
- Neighbourhood
  - Canadian Active Living Environments (Can-ALE)
  - Canadian Marginalization Index (CAN-Marg)
  - Noise
  - Proximity to Roads
  - Proximity to Water Bodies
- Weather
  - Climate Metrics
  - Water Balance Metrics
