
library(tidyr)
library(dplyr)
## to calcualte stratification 

names(df_merge)
yr_ls <- unique(df_merge$Year)
yr_ls


for (yr in yr_ls) {
  print(yr)

## Subset the vars that to be processed --------------------------------------------------
d <- df_merge %>% 
  
  ## for testing use, to reduce computation time at first
  dplyr::filter(Year == yr) %>%
  
  dplyr::mutate(n_day_ago = Date - date_img,
                n_day_ago = as.numeric(n_day_ago)) %>%
  # dplyr::filter(n_day_ago >= 0) %>%
  dplyr::select(1:3, n_day_ago, everything()) %>%
  dplyr::select(1:3, n_day_ago, velocity_u_0:water_temp_80, Depth)  

### |__ wide format to long format for easy filter ----
d1 <- d %>%
  tidyr::gather(key = vars, value = value, velocity_u_0:water_temp_80) #%>%


### |__ to get the sampling depth info ------
d2 <- d1 %>%
  ## --> separate the `var` column to get the sampling depth value
  dplyr::mutate(vars = gsub('ty_',   'tyXXX_',   vars),      ## add special chr for easy split
                vars = gsub('temp_', 'tempXXX_', vars)) %>%  ## add special chr for easy split
  separate(col = vars, into = c('var1', 'varX'), sep = 'XXX_', remove = F) %>%
  dplyr::mutate(#var1 = paste0(var1, 'y'), 
                var2 = sub("^([[:alpha:]]*).*", "\\1", varX),
                var  = paste0(var1, var2), # get the var name without depth info
                depth_sample = as.numeric(gsub("\\D", "", varX))) %>%
  dplyr::select(-var1, -var2, -varX, -vars) %>%
  # dplyr::filter(YEID == "2014_003") %>%  # for testing 
  dplyr::filter(depth_sample <= Depth) %>% # to filter the sampling depths that are smaller than the water depth 
  arrange(YEID, Date, n_day_ago, var, depth_sample)
# unique(d2$var)

### --> release some memory 
rm(d, d1)
gc()



## To calculate the difference between surface and bottom --------------------------------
### |__ to get the values on the bottom ----
d3_bottom <- d2 %>%  
  group_by(YEID, Date, `date_img`, n_day_ago, var) %>%
  slice_max(order_by = depth_sample, n = 1)
  
### |__ to get the values on the surface ----
d3_surface <- d2 %>%  
  group_by(YEID, Date, `date_img`, n_day_ago, var) %>%
  slice_min(order_by = depth_sample, n = 1)

# unique(d3_bottom$YEID)  %>% length()  
# unique(d3_surface$YEID) %>% length() %>% print()  


### |__ to cal the difference between surface and bottom (bottom - surface) ----
by <- subset(names(d3_surface), !names(d3_surface) %in% c('value', 'depth_sample')); 
# by

d4 <- merge(x = d3_surface %>% dplyr::select(-depth_sample), 
            y = d3_bottom  %>% dplyr::select(-depth_sample), 
            by = by) %>%
  dplyr::mutate(val_dif = value.y - value.x) %>%
  dplyr::mutate(var = paste0(var, '_dif'))

d5_dif <- d4 %>%
  dplyr::select(-value.x, -value.y) %>%
  pivot_wider(names_from = var, values_from = val_dif)

# hist(d5$salinity_dif)
# hist(d5$velocityu_dif)
# hist(d5$velocityv_dif)





## To generate the cleaned data ----------------------------------------------------------
### |__ might be useful to include the surface values ---- 
###     which can also be used to calculate the bottom values later if necessary
d5_sur <- d3_surface %>%
  dplyr::mutate(var = paste0(var, '_surface')) %>%
  dplyr::select(-depth_sample) %>%
  pivot_wider(names_from = var, values_from = value)

### |__ bind both the `difference` values and `surface` values together ----
d6 <- merge(x = d5_sur, y = d5_dif, by = c("YEID","Date","date_img","n_day_ago","Depth"))
unique(d6$YEID) %>% length() %>% print()  


### --> release some memory 
rm(d2, d4, d5_dif, d5_sur)
gc()



## Save RData ----------------------------------------------------------------------------
getwd()
f <- paste0('./data/from_gee/Img2Table_cleaned/rs_stratification/',
            'rs_dif_', yr, '.RData')   
save(d6, file = f)

}
