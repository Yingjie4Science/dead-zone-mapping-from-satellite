
library(tidyverse)
library(dplyr)
library(tidyr)
library(lubridate)

path <- rstudioapi::getSourceEditorContext()$path
dir  <- dirname(rstudioapi::getSourceEditorContext()$path)
dir.root <- dirname(dir)

dir.foodfootprint <- "D:/_papers/_phd_dissertation/food_footprints/"
dir.fert.data <- paste0(dir.foodfootprint, "data/ag_fertilizer/USGS_N_P_FertilizerManure_county1950_2017/")

dir.fig     <- paste0(dir.root, '/figures/')


## keep more decimals
options(digits = 15)
options(pillar.sigfig = 15)

### Disable Scientific Notation in R
options(scipen = 999) # Modify global options in R

today <- format(Sys.time(), "%Y%m%d"); print(today)

