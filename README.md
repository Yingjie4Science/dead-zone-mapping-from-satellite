# Dead Zone Mapping


## Code

- https://code.earthengine.google.com/?accept_repo=users/yingjieli/DZT

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
