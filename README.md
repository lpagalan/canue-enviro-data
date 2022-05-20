# Introduction
This script compiles annual environmental data from the [Canadian Urban Environmental Health Research Consortium](https://canue.ca) (CANUE) and prepares them for linkage to other datasets. CANUE data are provided as annual CSV files, and this code merges the annual datasets into one. The compiled dataset allows merging to other data using 6-digit postal code and year as a merge key. Data are available through the [CANUE Data Portal](https://www.canuedata.ca).

# Data
The script processes the following datasets:

- Air Quality
  - [Nitrogen Dioxide](Data/Air%20Quality/NO2/CANUE_METADATA_NO2LUR_A_YY.pdf) (NO<sub>2</sub>)
  - [Ozone](Data/Air%20Quality/O3/CANUE_METADATA_O3CHG_A_YY.pdf) (O<sub>3</sub>)
  - [Particulate Matter 2.5 micrometres and smaller](Data/Air%20Quality/PM2.5/CANUE_METADATA_PM25DALC_A_YY.pdf) (PM<sub>2.5</sub>)
- Greenness
  - [Landsat Normalized Difference Vegetation Index](Data/Greenness/NDVI) (NDVI)
- Neighbourhood
  - [Canadian Active Living Environments](Data/Neighbourhood/Can-ALE/CANUE_METADATA_ALE_A_YY.pdf) (Can-ALE)
  - [Canadian Marginalization Index](Data/Neighbourhood/CAN-Marg/CANUE_METADATA_CMG_A_YY.pdf) (CAN-Marg)
  - [Noise](Data/Neighbourhood/Noise/CANUE_METADATA_NHNSE_AVA_YY.pdf)
  - [Proximity to Roads](Data/Neighbourhood/Roads)
  - [Proximity to Water Bodies](Data/Neighbourhood/Water%20Bodies/CANUE_METADATA_DTW_A_YY.pdf)
- Weather
  - [Climate Metrics](Data/Weather/Climate/CANUE_METADATA_WTHNRC_A_YY.pdf)
  - [Water Balance Metrics](Data/Weather/Water%20Balance/CANUE_METADATA_WBNRC_A_YY.pdf)
