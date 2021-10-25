library(raster)
library(here)
library(dplyr)

set.seed(123)

buildings <- raster(here("data/buildings/building_count.tif"))
buildings <- buildings > 0
names(buildings) <- "building"
lidar <- stack(
  here("data/lidar/NYSGPO_ErieGeneseeLivingston2019_predictors.tiff")
)
names(lidar) <- names(stack(here("data/lidar/e1363n2352_2019.grd")))

full_stack <- addLayer(lidar, buildings)

buildings[is.na(lidar[["h90"]])] <- NA

sample_points <- sampleStratified(buildings, 2500, na.rm = T, sp = T)
model_data <- extract(full_stack, sample_points)
model_data <- as.data.frame(model_data) |>
  select(-n)

row_idx <- sample(1:nrow(model_data), nrow(model_data))
training <- model_data[row_idx <= 0.7 * nrow(model_data), ]
testing <- model_data[row_idx > 0.7 * nrow(model_data), ]

write.csv(
  training,
  here("data/training.csv"),
  row.names = F
)
write.csv(
  testing,
  here("data/testing.csv"),
  row.names = F
)
