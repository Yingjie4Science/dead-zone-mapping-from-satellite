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
    |   |__sample_2000_2019_DO.xlsx
    |
    |
    |__ data_from_gee
    |   |
    |   |__ Img2Table_cleaned
    |       |
    |       |__ by_timelag *(only pixel values)*
    |       |
    |       |__ by_timelag_withDO *(pixel + DO)*
    |
    |...
```