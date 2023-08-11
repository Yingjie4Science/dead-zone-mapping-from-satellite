import pandas as pd
from numpy import *
from sklearn.ensemble  import  RandomForestRegressor
from sklearn.model_selection  import  train_test_split
import warnings
from sklearn.metrics import mean_squared_error, r2_score, mean_absolute_error
import os
import sys

## need to change working directory when using Spyder 
path_current = os.getcwd()
path_root    = path_current #os.path.dirname(path_current)

index_list = ['Depth','water_temp_surface','water_temp_dif',
              'chlor_a','nflh','Rrs_678',
              # 'poc', 'sst', 'Rrs_667', 'Rrs_645',            ## not included by Zilong
              # 'Rrs_443', 'Rrs_412', 'Rrs_469', 'Rrs_488',    ## not included by Zilong
              # 'Rrs_555', 'Rrs_547', 'Rrs_531',               ## not included by Zilong, lowerest importance
              # 'wind_speed',	
              # 'velocityu_surface', 'velocityu_dif',
              # 'velocityu_surface',
              
              ### new to add
              'doy_img', 
              # 'nday_before',
              
              ### included 
              'salinity_surface','salinity_dif','velocityu_dif', 'lon','lat']


# path_data = 'D:\\D\\' ## Zilong
path_data = path_root + '\\data\\from_gee\\rs_do_sample\\rs_do_sample_lagByDay\\'


## to fit the model by year, or use all data as a whole
# by_year  = 'yes'
by_year  = 'no'


## create empty list in order to collect results from each run
lag_list = [];
yr_list  = [];

random_i = []
mae_list = []
mse_list = []
r2_list = []

zong_r2_list  = []
zong_mae_list = []
zong_mse_list = []



importance_df = pd.DataFrame()

for lag in range(0,81): # (0, 81) for initial test; (31,32) for the best lag
        print('lag: ' + str(lag))
        diamonds = pd.read_excel(path_data + 'RS_do_bottom_sample_2000_2019_byday_' + str(lag) + 'dayBefore.xlsx');

        for ite in index_list:  # 删除空值
            diamonds = diamonds[diamonds[ite].notna()]
        obj_num = []
        
        for yy in range(2003,2004): ## if by_year  = 'no', this line won't be used. 
            
            if by_year == 'yes':
                yr = yy
            else:
                yr = 1
  
            ## data test finds that only using data from 'SEAMAP' can achieve better accuracy
            diamonds2 = diamonds[diamonds['Source'] == 'SEAMAP'];
            # diamonds2 = diamonds;
            
            X = diamonds2[index_list]
            Y = diamonds2[['DO']]
            # mae_list = []
            # mse_list = []
            # r2_list = []
            for i in range(20):   #循环20次验证精度
                X_train ,  X_test ,  y_train ,  y_test  =  train_test_split( X , Y ,  test_size  = 0.3)
                regr = RandomForestRegressor() #参数默认
                regr.fit(X_train, y_train.values.ravel())
                warnings.filterwarnings('ignore')
                predictions = regr.predict(X_test)
                result = X_test
                result['price'] = y_test
                result['prediction'] = predictions.tolist()
                ## save the result
                if lag in [31, 32]:
                    file_name = path_root + '\\data\\results_RF\\rf_prediction_lag_' + str(lag) + 'loop' + str(i) + '.csv'
                    result.to_csv(file_name, index=False)
                
                mae = mean_absolute_error(y_test.values.ravel(), predictions)
                mse = mean_squared_error(y_test.values.ravel(), predictions)
                r2 = r2_score(y_test.values.ravel(), predictions)
                # print(r2)
                mse_list.append(mse)
                mae_list.append(mae)
                r2_list.append(r2)
                lag_list.append(lag)
                yr_list.append(yr)
                random_i.append(i)
                
                ## to get the variable importance score
                import_list = []
                score_list  = []
                
                characteristics = X.columns
                importances = list(regr.feature_importances_)
                characteristics_importances = [(characteristic, round(importance, 2)) for characteristic, importance in zip(characteristics, importances)]
                characteristics_importances = sorted(characteristics_importances, key = lambda x: x[1], reverse = True)
                for pair in characteristics_importances:
                    import_list.append(pair[0])
                    score_list.append(pair[1])
                # [print('Variable: {:20} Importance: {}'.format(*pair)) for pair in characteristics_importances]; #打印变量重要性
                imp_dict = {'year': yr,
                            'lag': lag,
                            'random_i': i,
                            'var': import_list,
                            'score': score_list}
                imp_df = pd.DataFrame(imp_dict)
                importance_df = importance_df.append(imp_df, ignore_index=True) ## this `append` in dataframe is different from that for a list


            ## calculate the mean of 20 models
            # print('Mean Absolute Error:',round(mean(mae_list),2))
            # print('Mean Squared Error:',round(mean(mse_list),2))
            print('R-squared scores:',round(mean(r2_list),4))
            # zong_r2_list.append(round(mean(r2_list),4))
            # zong_mae_list.append(round(mean(mae_list), 4))
            # zong_mse_list.append(round(mean(mse_list), 4))
            
            

# print(zong_r2_list)
# print(zong_mae_list)
# print(zong_mse_list)

# print(r2_list)
# print(lag_list)
# print(score_list)
# print(characteristics_importances)

# put the raw data into a dictionary of lists, and then convert it to a dataframe, then csv
dict = {'year': yr_list,
        'lag': lag_list,
        'random_i': random_i,
        'r2':  r2_list,
        'mae': mae_list,
        'mse': mse_list}
# creating a dataframe from list
df = pd.DataFrame(dict)

file_name = path_root + '\\data\\results_RF\\rf_r2_mse_mae_' + 'by_year' + by_year.upper() + '_' + str(len(index_list)) + 'vars.csv'
# df.to_csv(file_name, index=False)

file_name = path_root + '\\data\\results_RF\\rf_importance_' + 'by_year' + by_year.upper() + '_' + str(len(index_list)) + 'vars.csv'
# importance_df.to_csv(file_name, index=False)

