
# This script compiles annual environmental data from the Canadian Urban
# Environmental Health Research Consortium (CANUE) and prepares them for linkage
# to other datasets. CANUE provides data as annual CSV files, and this code
# merges the annual files into one. The compiled datasets (e.g., one file
# containing NO2 data across multiple years) allow linking to other data using a
# 6-digit postal code and year as a merge key. Data are available through the
# CANUE Data Portal.

# Load libraries ----------------------------------------------------------

library(tidyverse)
library(knitr)

# Select data to process --------------------------------------------------

# Edit values to TRUE or FALSE to process the respective data

process_no2           <- TRUE
process_o3            <- TRUE
process_pm25          <- TRUE
process_ndvi          <- TRUE
process_can_ale       <- TRUE
process_can_marg      <- TRUE
process_noise         <- TRUE
process_roads         <- TRUE
process_water_bodies  <- TRUE
process_climate       <- TRUE
process_water_balance <- TRUE

# Set time range of interest ----------------------------------------------

min_year <- 2000
max_year <- 2017

# Set input directories ---------------------------------------------------

# Edit dir_var path to the location of the unzipped folders containing CANUE
# environmental data for compiling (i.e., process_var is TRUE). Ignore
# directories of datasets were process_var is FALSE.

# Air quality

dir_no2  <- "Data/Air Quality/NO2"
dir_o3   <- "Data/Air Quality/O3"
dir_pm25 <- "Data/Air Quality/PM2.5"

# Greenness

dir_ndvi <- "Data/Greenness/NDVI/"

# Neighbourhood

dir_can_ale      <- "Data/Neighbourhood/Can-ALE"
dir_can_marg     <- "Data/Neighbourhood/CAN-Marg"
dir_noise        <- "Data/Neighbourhood/Noise"
dir_roads        <- "Data/Neighbourhood/Roads"
dir_water_bodies <- "Data/Neighbourhood/Water Bodies"

# Weather

dir_climate       <- "Data/Weather/Climate"
dir_water_balance <- "Data/Weather/Water Balance"

# Verify file name pattern ------------------------------------------------

# Check that unzipped CSV files match the file name pattern. The regex pattern
# "\\d{2}" corresponds to CANUE's "YY" suffix naming convention referring to the
# data's corresponding year. Ignore file names of datasets were process_var is
# FALSE.

# Air quality

file_name_pattern_no2  <- "no2lur_a_\\d{2}.csv"
file_name_pattern_o3   <- "o3chg_a_\\d{2}.csv"
file_name_pattern_pm25 <- "pm25dalc_a_\\d{2}.csv"

# Greenness

file_name_pattern_ndvi <- "grlan_amn_\\d{2}.csv"

# Neighbourhood

file_name_pattern_can_ale      <- "ale_a_\\d{2}.csv"
file_name_pattern_can_marg     <- "cmg_a_\\d{2}.csv"
file_name_pattern_noise        <- "nhnse_ava_\\d{2}.csv"
file_name_pattern_roads        <- "dtr_a_\\d{2}.csv"
file_name_pattern_water_bodies <- "dtw_a_\\d{2}.csv"

# Weather

file_name_pattern_climate       <- "wthnrc_a_\\d{2}.csv"
file_name_pattern_water_balance <- "wbnrc_a_\\d{2}.csv"

# Set null values to NA ---------------------------------------------------

is_replace_null <- TRUE

canue_null <- c("", "NA", "-9999", "null", "NULL", "-1111")

# Set output directory ----------------------------------------------------

# Edit dir_output path where compiled datasets will be exported. If the
# directory does not exist, R will create a new folder.

dir_output <- "Results"

if (!file.exists(dir_output)) {
  dir.create(file.path(dir_output))
}

# Set output filenames ----------------------------------------------------

file_no2           <- "air_quality_no2.rds"
file_o3            <- "air_quality_o3.rds"
file_pm25          <- "air_quality_pm25.rds"
file_ndvi          <- "greenness_ndvi.rds"
file_can_ale       <- "neighbourhood_can_ale.rds"
file_can_marg      <- "neighbourhood_can_marg.rds"
file_noise         <- "neighbourhood_noise.rds"
file_roads         <- "neighbourhood_roads.rds"
file_water_bodies  <- "neighbourhood_water_bodies.rds"
file_climate       <- "weather_climate.rds"
file_water_balance <- "weather_water_balance.rds"

# If files exists, choose to skip or override -----------------------------

is_override_data <- TRUE

# No user modifications are required below --------------------------------

# Functions ---------------------------------------------------------------

# Function checks output directory if processed files exists. If processed files
# exists, the variable is_override_data determines whether to (a.)
# process the data again and override existing files or (b.) skip and retain the
# existing files, speeding up the script.

override_check <- function(var_process, file_var) {
  if (var_process) {
    if (file.exists(file.path(dir_output, file_var))) {
      if (!get("is_override_data", envir = globalenv())) {
        var_process <- FALSE
      }
    }
  }
  return(var_process)
}

process_no2           <- override_check(process_no2,           file_no2)
process_o3            <- override_check(process_o3,            file_o3)
process_pm25          <- override_check(process_pm25,          file_pm25)
process_ndvi          <- override_check(process_ndvi,          file_ndvi)
process_can_ale       <- override_check(process_can_ale,       file_can_ale)
process_can_marg      <- override_check(process_can_marg,      file_can_marg)
process_noise         <- override_check(process_noise,         file_noise)
process_roads         <- override_check(process_roads,         file_roads)
process_water_bodies  <- override_check(process_water_bodies,  file_water_bodies)
process_climate       <- override_check(process_climate,       file_climate)
process_water_balance <- override_check(process_water_balance, file_water_balance)

# Function automatically loads annual files located within a directory
# containing CANUE environmental data. The function scans the directory for a
# list of valid files. The list of annual files are then filtered based on the
# specified time range of interest. Column names are stripped of their two-digit
# year suffix and instead given a new column containing the year of the
# corresponding annual file. Annual files are then compiled into one file.

compile_annual_files <- function(dir_input,
                                 file_name_pattern,
                                 min_year,
                                 max_year) {

    # Get list of annual datasets

    files <- list.files(path = dir_input, pattern = file_name_pattern)

    # Determine the years of the annual datasets by extracting the 2-digit
    # numeric suffix from file names

    years <- str_sub(files, -6, -5)

    # Add respective century prefix to corresponding year

    for (i in seq_along(years)) {
      if (as.numeric(years[i]) >= 80) {
        years[i] <- paste0("19", years[i])
      } else {
        years[i] <- paste0("20", years[i])
      }
    }

    # Create data frame with file name and corresponding year

    df_annual_datasets <- tibble(file = files, year = years)

    # Filter to time range of interest

    df_annual_datasets <- filter(df_annual_datasets,
                                 year >= min_year & year <= max_year)


    # Function loads an annual dataset, adds a column for the corresponding
    # year, and removes year suffixes in existing columns

    process_annual_file <- function(dir_input,
                                    file,
                                    year) {

      # Load annual file, replace null, and add column with corresponding year

      if (get("is_replace_null", envir = globalenv())) {
        annual_file <- read_csv(file.path(dir_input, file),
                                na = get("canue_null", envir = globalenv()))
      } else {
        annual_file <- read_csv(file.path(dir_input, file))
      }

      annual_file <- mutate(annual_file, year = year)

      # Remove two-digit year suffix from column names

      col_names <- names(annual_file) %>%
        str_remove("\\d{2}(?=_)") %>% # Remove YY from varYY_XX
        str_remove("(?<!_)\\d{2}\\b") # Remove YY from postalcodeYY

      names(annual_file) <- col_names
      return(annual_file)
    }

    # Process each annual file and then combine them into one

    compiled_annual_files <- map2(df_annual_datasets$file,
                                  df_annual_datasets$year,
                                  process_annual_file,
                                  dir = dir_input) %>%
      bind_rows()

    # Summarize number of observations by annual file

    summary_annual_files <- compiled_annual_files %>%
      mutate(year = as.factor(year)) %>%
      arrange(year) %>%
      group_by(year) %>%
      summarise(observations = n())

    full_join(df_annual_datasets, summary_annual_files, by = "year") %>%
      kable() %>%
      print()

    return(compiled_annual_files)
  }

# Process NO2 -------------------------------------------------------------

if (process_no2) {
  compile_annual_files(
    dir_input         = dir_no2,
    file_name_pattern = file_name_pattern_no2,
    min_year          = min_year,
    max_year          = max_year
  ) %>%
    saveRDS(file.path(dir_output, file_no2))
}

# Process O3 --------------------------------------------------------------

if (process_o3) {
  compile_annual_files(
    dir_input         = dir_o3,
    file_name_pattern = file_name_pattern_o3,
    min_year          = min_year,
    max_year          = max_year
  ) %>%
    saveRDS(file.path(dir_output, file_o3))
}

# Process PM2.5 -----------------------------------------------------------

if (process_pm25) {
  compile_annual_files(
    dir_input         = dir_pm25,
    file_name_pattern = file_name_pattern_pm25,
    min_year          = min_year,
    max_year          = max_year
  ) %>%
    saveRDS(file.path(dir_output, file_pm25))
}

# Process NDVI ------------------------------------------------------------

if (process_ndvi) {
  compile_annual_files(
    dir_input         = dir_ndvi,
    file_name_pattern = file_name_pattern_ndvi,
    min_year          = min_year,
    max_year          = max_year
  ) %>%
    saveRDS(file.path(dir_output, file_ndvi))
}

# Process Can-ALE ---------------------------------------------------------

if (process_can_ale) {
  compile_annual_files(
    dir_input         = dir_can_ale,
    file_name_pattern = file_name_pattern_can_ale,
    min_year          = min_year,
    max_year          = max_year
  ) %>%
    saveRDS(file.path(dir_output, file_can_ale))
}

# Process CAN-Marg --------------------------------------------------------

if (process_can_marg) {
  compile_annual_files(
    dir_input         = dir_can_marg,
    file_name_pattern = file_name_pattern_can_marg,
    min_year          = min_year,
    max_year          = max_year
  ) %>%
    saveRDS(file.path(dir_output, file_can_marg))
}

# Process Noise -----------------------------------------------------------

if (process_noise) {
  compile_annual_files(
    dir_input         = dir_noise,
    file_name_pattern = file_name_pattern_noise,
    min_year          = min_year,
    max_year          = max_year
  ) %>%
    saveRDS(file.path(dir_output, file_noise))
}

# Process Proximity to Roads ----------------------------------------------

if (process_roads) {
  compile_annual_files(
    dir_input         = dir_roads,
    file_name_pattern = file_name_pattern_roads,
    min_year          = min_year,
    max_year          = max_year
  ) %>%
    saveRDS(file.path(dir_output, file_roads))
}

# Process Proximity to Water Bodies ---------------------------------------

if (process_water_bodies) {
  compile_annual_files(
    dir_input         = dir_water_bodies,
    file_name_pattern = file_name_pattern_water_bodies,
    min_year          = min_year,
    max_year          = max_year
  ) %>%
    saveRDS(file.path(dir_output, file_water_bodies))
}

# Process Climate ---------------------------------------------------------

if (process_climate) {
  compile_annual_files(
    dir_input         = dir_climate,
    file_name_pattern = file_name_pattern_climate,
    min_year          = min_year,
    max_year          = max_year
  ) %>%
    saveRDS(file.path(dir_output, file_climate))
}

# Process Water Balance ---------------------------------------------------

if (process_water_balance) {
  compile_annual_files(
    dir_input         = dir_water_balance,
    file_name_pattern = file_name_pattern_water_balance,
    min_year          = min_year,
    max_year          = max_year
  ) %>%
    saveRDS(file.path(dir_output, file_water_balance))
}

rm(list = ls())
