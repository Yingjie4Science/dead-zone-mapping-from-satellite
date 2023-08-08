


## ref: https://www.neonscience.org/resources/learning-hub/tutorials/dc-raster-rastervis-levelplot-r
library(raster)
library(rgdal)
library(rasterVis)


library(RColorBrewer)

library(tidyverse)



# set working directory to ensure R can find the file we wish to import
getwd()
wd <- "./data/data_from_gee/predict_do_maps/" # this will depend on your local environment environment
# be sure that the downloaded file is in this directory
# setwd(wd)
dir.fig    <- './figures/'; dir.fig



# Create list of NDVI file paths
all_NDVI_HARV <- list.files(path = wd, full.names = TRUE, pattern = "do_map_.*.tif$"); all_NDVI_HARV

# Create a time series raster stack
NDVI_HARV_stack <- stack(all_NDVI_HARV)

# plot(NDVI_HARV_stack, nc = 4)





# create a `levelplot` plot

# use colorbrewer which loads with the rasterVis package to generate
# a color ramp of yellow to green
cols <- colorRampPalette(brewer.pal(9,"RdYlBu"))


# use gsub to modify label names.that we'll use for the plot 
rasterNames  <- gsub("do_map_", " ", names(NDVI_HARV_stack))
# use level plot to create a nice plot with one legend and a 4x4 layout.
png(file=paste0(dir.fig, 'do_maps_1weekORweekly_2014.png'),width=16, height=9, units = 'in', res = 300)
levelplot(NDVI_HARV_stack,
          layout=c(4, 6), # create a 4x6 layout for the data
          col.regions=cols, # add a color ramp
          main="Weekly DO level (mg/l) in 2014 \npredicted via RF",
          names.attr=rasterNames,
          # colorkey=list(title=expression(mg/l)),
          scales=list(draw=FALSE)) # remove axes labels & ticks
dev.off()




### bi-weekly map
all_NDVI_HARV
r1 <- "./data/data_from_gee/predict_do_maps/do_map_20140501.tif" 
r2 <- "./data/data_from_gee/predict_do_maps/do_map_20140508.tif"

# GDALinfo(r1)
# GDALinfo(r2)


r1 <- raster(r1)
r2 <- raster(r2)


plot(r1)
# plot(r2)
# 
# a <- mean(r1, r2, rm.na = T)
# a <- min(r1, r2, rm.na = F)
# a <- min(r1, r2)
# plot(a)


## Replace NA values in the first Raster object (x) with the values of the second (y)
## #  If TRUE overlapping areas are intersected rather than replaced
# b <- cover(r1, r2, identity = T); plot(b)
# b <- cover(r1, r2, identity = F); plot(b)
# b <- cover(r2, r1); plot(b)
# b <- cover(r2, r1, identity = T); plot(b)


min <- min(r1, r2, na.rm=T); plot(min)
# min <- raster::overlay(r1,r2,fun=min,na.rm=T); plot(min)
# min <- raster::calc(stack(r1,r2),fun=min,na.rm=T); plot(min)

mean <- mean(r1, r2, na.rm=T)
r12 <- cover(r1, r2); #plot(r12)
r21 <- cover(r2, r1); #plot(r21)
r12c <- cover(r12, r21) 
r3   <- r12c- r12; 
minc12 <- cover(min, r1, r2); 
minc21 <- cover(min, r2, r1) - minc12

# plot(min - minc12) ## --> no need to use minc12

rstack <-     stack(r1,   r2,   r12,   r21,   min,   minc12,   mean)
names(rstack) <- c('r1', 'r2', 'r12', 'r21', 'min', 'minc12', 'mean')
# plot(rstack, nc=2)
levelplot(rstack, 
          col.regions=cols,
          layout=c(2, 4))

# CHM_ov_HARV<- raster::overlay(r1, r2,
#                       # fun=function(r1, r2) {return (r1 - r2)}
#                       fun = min ## sum, mean, min
#                       )
# 
# plot(CHM_ov_HARV, main="Canopy")







## 2 weeks -----------------------------------------------------------------------------------------
odds <- seq(1, length(all_NDVI_HARV), 2); odds

do_biweek_stack  <- stack()
do_biweek_stackc <- stack()

for (i in odds) {
  odd <- all_NDVI_HARV[i]; print(odd)
  even<- all_NDVI_HARV[i+1]; print(even); 
  
  name1 <- gsub('do_map_2014|.tif', '', basename(odd))
  name2 <- gsub('do_map_2014|.tif', '', basename(even))
  name  <- paste0('week ', name1, '-', name2)
  print(name)
  print('---')
  
  r1 <- raster(odd)
  r2 <- raster(even)

  min  <- min(r1, r2, na.rm=T);
  minc <- cover(min, r1, r2)
  names(min)  <- name
  names(minc) <- name

  do_biweek_stack  <- stack(do_biweek_stack, min)
  do_biweek_stackc <- stack(do_biweek_stackc, minc)
}

names(do_biweek_stack)
png(file=paste0(dir.fig, 'do_maps_2weekORbiweekly_2014.png'),width=16, height=9, units = 'in', res = 300)
levelplot(do_biweek_stack, 
          col.regions=cols,
          main="Bi-weekly DO level (mg/l) in 2014 \npredicted via RF",
          layout=c(2, 6))
dev.off()


## for MS use
png(file=paste0(dir.fig, 'do_maps_2weekORbiweekly_2014_Fig5a.png'),width=8, height=3.5, units = 'in', res = 300)
levelplot(do_biweek_stack, 
          col.regions=cols,
          # main="Bi-weekly DO level (mg/l) in 2014 \npredicted via RF",
          layout=c(4, 3))
dev.off()

# levelplot(do_biweek_stackc, 
#           col.regions=cols,
#           layout=c(2, 6))






## 4 weeks -----------------------------------------------------------------------------------------

odds <- seq(1, length(all_NDVI_HARV), 4); odds

do_stack  <- stack()

for (i in odds) {
 
  w1 <- all_NDVI_HARV[i];   print(w1)
  w2 <- all_NDVI_HARV[i+1]; print(w2); 
  w3 <- ifelse(i+2 < length(all_NDVI_HARV), all_NDVI_HARV[i+2], w2); print(w3); 
  w4 <- ifelse(i+3 < length(all_NDVI_HARV), all_NDVI_HARV[i+3], w3); print(w4); 
  
  name1 <- gsub('do_map_2014|.tif', '', basename(w1))
  name2 <- gsub('do_map_2014|.tif', '', basename(w4))
  name  <- paste0('week ', name1, '-', name2)
  print(name)
  print('---')
  
  r1 <- raster(w1)
  r2 <- raster(w2)
  r3 <- raster(w4)
  r4 <- raster(w4)
  
  min  <- min(r1, r2, r3, r4, na.rm=T);
  names(min)  <- name

  
  do_stack  <- stack(do_stack, min)
}

names(do_stack)
png(file=paste0(dir.fig, 'do_maps_4weekORmonthly_2014.png'),width=16, height=9, units = 'in', res = 300)
levelplot(do_stack, 
          col.regions=cols,
          main="Monthly DO level (mg/l) in 2014 \npredicted via RF",
          layout=c(1, 6))
dev.off()
