library(raster)
library(here)
source(here("code/reproject.R"))

align_raster <- raster(
  here("data/lidar/NYSGPO_ErieGeneseeLivingston2019_predictors.tiff")
)
# nys <- labrador.client::get_region("state_shorline")

reproject_gdal(
  here("data/buildings/raw/NewYork_cnt.tif"),
  align_raster@crs,
  here("data/buildings/building_count.tif"),
  align_raster,
  res = 30,
  method = "nearest",
  brick = FALSE
)

