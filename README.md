# Dead Zone Mapping


## Code

- **01_DO_dataset_cleaning.Rmd**



- **02_DO_format_for_model.Rmd**



- **03_spectral data at sampling locations.Rmd**
  
  To clean the data downloaded from GEE, and to link the image band info with DO data. 
  
  
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