


library(sf)
library(raster)
## read in one file
dir.freq <- "./data/results_RF/dz_frequency_2000_2019/"
yr <- 2000
ras <- paste0(dir.freq, 'dz_frequency_', yr, '.tif'); ras
ras <- raster(ras)
ras[ras <= 0] <- NA
ras_crs <- crs(ras)

crs(ras)
# st_crs(ras)

## to get a boundary box 
bb <- st_bbox(ras, crs = crs(ras));  ## , crs = st_crs(4326)
bb
## change projection to get the lat and lon
bb_ll = st_bbox(st_transform(x = st_as_sfc(bb), crs = 4326)) 
bb_ll
## crop the box or reduce the focus region for plotting
bb_ll['ymin'] <- 27
bb_ll[2]

## change back to the original projection
bb2 <- st_bbox(st_transform(x = st_as_sfc(bb_ll), crs = crs(ras)))
bb2
bb

## to generate sfc file 
bb_sf <- st_as_sfc(bb2)
bb_sf <- st_transform(bb_sf, crs = 4326)



### river data ---------------------------------------------------------------------------
# rivers <- '../Dead_Zone_telecoupling/data/shp/TWAP_rivers.shp'
# riv <- st_read(rivers) %>% st_as_sf() %>% 
#   dplyr::select(name) %>%
#   dplyr::rename(river_name = name)

rivers <- '../Dead_Zone_telecoupling/data/shp/rs16my07/rs16my07.shp'
riv_ <- st_read(rivers) %>% st_as_sf() 
rive  <- riv_ %>% 
  dplyr::select(PNAME, PMILE) %>%
  dplyr::rename(river_name = PNAME) %>%
  dplyr::filter(str_detect(river_name, 'MISSISSIPPI|ATCHAFALAYA|SUWANNEE')) %>%
  dplyr::mutate(
    river_name = ifelse(str_detect(river_name, 'MISSISSIPPI'), 'Mississippi', river_name),
    river_name = ifelse(str_detect(river_name, 'ATCHAFALAYA'), 'Atchafalaya', river_name),
    river_name = ifelse(str_detect(river_name, 'SUWANNEE'), 'Suwannee', river_name),
  )

# Dissolve lines by group_id
riv <- rive %>%
  dplyr::group_by(river_name) %>%
  dplyr::summarize(geometry = st_union(geometry)) 
# plot(dissolved_sf)



### state boundary data ------------------------------------------------------------------
shp <- 'D:/data/shp/NaturalEarthData/ne_50m_admin_1_states_provinces/ne_50m_admin_1_states_provinces.shp'
usa <- sf::st_read(shp) %>%
  st_as_sf() %>%
  dplyr::filter(adm0_a3 == 'USA') %>%
  dplyr::select(name)
# st_crs(usa)
st_crs(bb_sf)
st_crs(riv)
st_crs(riv) <- st_crs(bb_sf)
# st_crs(bb)
# usa_gulf <- st_crop(usa, bb_sf)

riv_cropped <- st_crop(riv, bb_sf)
riv_cropped_simp <- st_simplify(x = riv_cropped)
# plot(riv_cropped)
# plot(riv)
plot(riv_cropped_simp)

f <- gsub('\\.shp', '_clip.shp', rivers); f
# st_write(obj = riv_cropped_simp, dsn = f, delete_layer = T)