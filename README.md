# Dead Zone Mapping


## Code

### GEE scripts
```
https://code.earthengine.google.com/?accept_repo=users/yingjieli/DZT
```

### R scripts
```
## Data pre-clening 
10_DO1_byMatli_data_cleaning.Rmd                      
11_DO1+DO2HypoxiaWatch_DataDesc.Rmd
22_Format_DO.Rmd ------------------------------------- Figure 2, S2, S3
31_Format_RS.Rmd
32_Link_RS_DO_for each locations.Rmd                  
40_Correlation_among variables_RS_DO.Rmd
41_chla_satellite_vs_obsRmd.Rmd

## Modeling                       
62_RF_model.Rmd
63_RF_Zilong_edited_20240506.ipynb
64_Figure_importance_Var.Rmd ------------------------- Figure 4, S4, S7
65_1_Figure_model_performance.Rmd -------------------- Figure 5
65_2_errorMap.Rmd ------------------------------------ Figure 8b

## Supporting data                                     
66_Figure_areaTimeseries_Maps.Rmd -------------------- Figure 6, 7, 9, 10
70_fertilizer_NP_byCounty.Rmd ------------------------ Figure S6
```  
  
## Data
```
  data
    |__ data_for_gee
    |   |__ sample_2000_2019_DO.xlsx     *(DO data at all depth levels)*
    |   |__ sample_2000_2019_DO_min.xlsx *(min DO at one location across the profile)*
    |
    |
    |__ data_from_gee
    |   |
    |   |__ Img2Table_04_2021-03-18 *(most updated image band data downloaded from GEE)*
    |   |
    |   |__ Img2Table_cleaned       
    |       |
    |       |__ by_timelag        *(only pixel values, extracted by considering different time lags)*
    |       |
    |       |__ by_timelag_withDO *(pixel + DO)*
    |
    |...
```

## Authors
The authors thank the Environmental Science and Policy Program Summer Research Fellowship for their financial support.
- [Dr. Yingjie Li](https://github.com/Yingjie4Science)<sup>1</sup>
- Zilong Xia
- Dr. Lan Nguyen
- Dr. Ho Yi Wan
- ...
- [Prof. Jianguo Liu](https://www.canr.msu.edu/people/jianguo_jack_liu)<sup>2</sup>

<sup>1</sup>Stanford University  
<sup>2</sup>Michigan State University
