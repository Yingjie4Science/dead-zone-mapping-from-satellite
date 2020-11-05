# set work dir
path <- rstudioapi::getSourceEditorContext()$path
dir  <- dirname(rstudioapi::getSourceEditorContext()$path); dir
setwd(dir)
getwd()
dir.user <- './Img2Table/processing'
dir.rs   <- './Img2Table/Img2Table_04_20191115' ## remote sensing data 
dir.st   <- './hypoxia_watch_GOM_csv_copy'      ## station info
library(tidyverse)
#list all csv files in data folder
csv_files <- list.files(dir.rs, pattern='*.csv')

#extract year from filenames
years <- as.numeric(substr(csv_files, 1, 4))
#print number of csv files for each year. Note: 2001, 2006, 2014, 2018 only have 14 files (instead of 28)
print(table(years))
years  %>% table() %>% as.data.frame() %>% setNames(c('year', 'count'))%>% 
  ggplot(aes(x=year, y=count, fill = count)) + geom_col() + theme_bw()+
  theme(axis.text.x = element_text(angle = 45, hjust = 1))

years <- unique(years); years

#extract sensor from filenames
sensors <- substr(csv_files, 6, 9)
#print number of csv files for sensor. Note: more csv files for terra than for aqua
print(table(sensors)) #print number of csv files for each sensor
sensors <- unique(sensors); sensors

params <- substr(csv_files, 11, nchar(csv_files) - 4); params
params  %>% table()
params  %>% table() %>% as.data.frame() %>% setNames(c('params', 'count'))%>% 
  ggplot(aes(x=params, y=count, fill = count)) + geom_col() + theme_bw() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))
params <- unique(params); params
params <- params[1:14]  ; params

stations <- list.files(dir.st, pattern='*.csv'); stations

years <- c(2003, 2004, 2005, 2007, 2009, 2010, 2011, 2012, 2013, 2015, 2016, 2017)
# years <- seq(2002, 2018); years
timeframes <- list(c(1, 7), c(8, 15), c(16, 22), c(23, 30), c(31, 37), c(38, 45), c(46, 52), c(53, 60)); timeframes

###---Single Sensor
for (yr in years){
  print(yr)
  stations_yr <- read.csv(paste0(dir.st, '/', stations[grep(yr, stations)]), stringsAsFactors = FALSE)
  colnames(stations_yr) <- toupper(colnames(stations_yr))
  colnames(stations_yr)[grep('DATE', colnames(stations_yr))] <- 'DATEUTC'
  for (ss in sensors){
    print(ss)
    lookup <- grep(paste0(toString(yr), '_', ss), csv_files)
    if (length(lookup)>0) {
      count_pr = 1
      observations <- data.frame(matrix(nrow=500, ncol=length(params) + 1 + 15))
      colnames(observations) <- c('Length', params, '1w_1', '1w_2', '1w_3', '1w_4', '1w_5', '1w_6', '1w_7', '1w_8',
                                  '2w_1', '2w_2', '2w_3', '2w_4', '1m_1', '1m_2', '2m')
     
      for (pr in params){
        print(pr)
        df <- read.csv(paste0(dir.rs, '/', yr, '_', ss, '_', pr, '.csv'), stringsAsFactors=FALSE)
        colnames(df) <- toupper(colnames(df))
        #extract keys info of stations
        station <- subset(df, select=c("STATION"))
        station <- merge(station, stations_yr, by=c("STATION"))
        station$DATEUTC <- format(strptime(station$DATEUTC, format="%m/%d/%Y"), "%Y.%m.%d")
        #get column names of df
        cnames <- colnames(df)
        #get column index of first observation
        mincol <- min(grep(paste0('X', yr), cnames))
        #get column index of last observation
        maxcol <- max(grep(paste0('X', yr), cnames))
        #separate remote sensing data from df
        data <- df[,mincol:maxcol]
        for (i in c(1:nrow(df))) {
          date <- station$DATEUTC[i]
          #find column index of the date of field observation
          col_tracking <- grep(date, cnames) - mincol
          #extract data of the last 60 days from the date of field observation
          data_2m <- as.numeric(data[i,(col_tracking-60):(col_tracking-1)])
          data_2m <- rev(data_2m)
          observations[i, 1] = length(data_2m)
          observations[i, count_pr + 1] = length(data_2m) - sum(is.na(data_2m))
          if (pr=='chlor_a') {
            count_tf <- 1
            for (tf in timeframes) {
              tf <- unlist(tf)
              sb <- data_2m[tf[1]:tf[2]]
              observations[i, length(params) + 1 + count_tf] = length(sb) - sum(is.na(sb))
              count_tf <- count_tf + 1
            }
          }
        }
        count_pr <- count_pr + 1
      }
      
      observations$`2w_1` <- observations$`1w_1` + observations$`1w_2`
      observations$`2w_2` <- observations$`1w_3` + observations$`1w_4`
      observations$`2w_3` <- observations$`1w_5` + observations$`1w_6`
      observations$`2w_4` <- observations$`1w_7` + observations$`1w_8`
      observations$`1m_1` <- observations$`2w_1` + observations$`2w_2`
      observations$`1m_2` <- observations$`2w_3` + observations$`2w_4`
      observations$`2m`   <- observations$`1m_1` + observations$`1m_2`
      observations <- observations[1:nrow(df),]
      write.csv(observations, paste0(dir.user, '/Observations_', yr, '_', ss, '.csv'))
    }
  }
}

###---Both Sensors
for (yr in years){
  print(yr)
  stations_yr <- read.csv(paste0('./Data/hypoxia_watch_GOM_csv/', stations[grep(yr, stations)]), stringsAsFactors = FALSE)
  colnames(stations_yr) <- toupper(colnames(stations_yr))
  colnames(stations_yr)[grep('DATE', colnames(stations_yr))] <- 'DATEUTC'
  count_pr = 1
  observations <- data.frame(matrix(nrow=500, ncol=length(params) + 1 + 15))
  colnames(observations) <- c('Length', params, '1w_1', '1w_2', '1w_3', '1w_4', '1w_5', '1w_6', '1w_7', '1w_8',
                              '2w_1', '2w_2', '2w_3', '2w_4', '1m_1', '1m_2', '2m')
  for (pr in params){
    print(pr)
    df_t <- read.csv(paste0('./Data/Img2Table_04_20191018', yr, '_terr_', pr, '.csv'), stringsAsFactors=FALSE)
    colnames(df_t) <- toupper(colnames(df_t))
    df_a <- read.csv(paste0('./Data/Img2Table_04_20191018', yr, '_aqua_', pr, '.csv'), stringsAsFactors=FALSE)
    colnames(df_a) <- toupper(colnames(df_a))
    #extract keys info of stations
    station <- subset(df_t, select=c("STATION"))
    station <- merge(station, stations_yr, by=c("STATION"))
    station$DATEUTC <- format(strptime(station$DATEUTC, format="%m/%d/%Y"), "%Y.%m.%d")
    #get column names of df
    cnames_a <- colnames(df_a)
    cnames_t <- colnames(df_t)
    #get column index of first observation
    mincol_a <- min(grep(paste0('X', yr), cnames_a))
    mincol_t <- min(grep(paste0('X', yr), cnames_t))
    #get column index of last observation
    maxcol_a <- max(grep(paste0('X', yr), cnames_a))
    maxcol_t <- max(grep(paste0('X', yr), cnames_t))
    #separate remote sensing data from df
    data_a <- df_a[,mincol_a:maxcol_a]
    data_t <- df_t[,mincol_t:maxcol_t]
    for (i in c(1:nrow(df_a))) {
      date <- station$DATEUTC[i]
      #find column index of the date of field observation
      col_tracking_t <- grep(date, cnames_t) - mincol
      col_tracking_a <- grep(date, cnames_a) - mincol
      #extract data of the last 60 days from the date of field observation
      data_2m_t <- as.numeric(data_t[i,(col_tracking_t-60):(col_tracking_t-1)])
      data_2m_a <- as.numeric(data_a[i,(col_tracking_a-60):(col_tracking_a-1)])
      data_2m_t[is.na(data_2m_t)] <- 0
      data_2m_a[is.na(data_2m_a)] <- 0
      data_2m <- data_2m_t + data_2m_a
      data_2m[data_2m==0] <- NA
      data_2m <- rev(data_2m)
      observations[i, 1] <- length(data_2m)
      observations[i, count_pr + 1] = length(data_2m) - sum(is.na(data_2m))
      if (pr=='chlor_a') {
        count_tf <- 1
        for (tf in timeframes) {
          tf <- unlist(tf)
          sb <- data_2m[tf[1]:tf[2]]
          observations[i, length(params) + 1 + count_tf] = length(sb) - sum(is.na(sb))
          count_tf <- count_tf + 1
        }
      }
    }
    count_pr <- count_pr + 1
  }
  observations$`2w_1` <- observations$`1w_1` + observations$`1w_2`
  observations$`2w_2` <- observations$`1w_3` + observations$`1w_4`
  observations$`2w_3` <- observations$`1w_5` + observations$`1w_6`
  observations$`2w_4` <- observations$`1w_7` + observations$`1w_8`
  observations$`1m_1` <- observations$`2w_1` + observations$`2w_2`
  observations$`1m_2` <- observations$`2w_3` + observations$`2w_4`
  observations$`2m`   <- observations$`1m_1` + observations$`1m_2`
  observations <- observations[1:nrow(df_a),]
  write.csv(observations, paste0(dir.user, '/Observations_', yr, '.csv'))
}

# data_2m[1:7]
# data_2m[8:15]
# data_2m[16:22]
# data_2m[23:30]
# data_2m[31:37]
# data_2m[38:45]
# data_2m[46:52]
# data_2m[53:60]

vars <- c("chlor_a", "nflh", "poc", "Rrs_412")

ratio <- data.frame(matrix(ncol=5, nrow=length(years)))
colnames(ratio) <- c('Year', 'Total', 'GE8_Aqua', 'GE8_Terr', 'GE16_Comb')
count <- 1
yr <- 2015

df_a <- read.csv(paste0('./Observations_Single_Sensor/Observations_', yr, '_aqua.csv'), stringsAsFactors=FALSE)
df_t <- read.csv(paste0('./Observations_Single_Sensor/Observations_', yr, '_terr.csv'), stringsAsFactors=FALSE)
df   <- read.csv(paste0('./Observations_Both_Sensors/Observations_', yr, '.csv'), stringsAsFactors=FALSE)

# par(mfrow=c(2,2), mar = c(4, 4, 1, 1))
# for (var in vars) {
#   data_a <- df_a[,colnames(df_a)==var]
#   data_a <- data.frame(table(data_a))
#   data_t <- df_t[,colnames(df_t)==var]
#   data_t <- data.frame(table(data_t))
#   data <- df[,colnames(df)==var]
#   data <- data.frame(table(data), stringsAsFactors = FALSE)
#   xmin <- min(min(as.numeric(as.character(data_t$data_t))), min(as.numeric(as.character(data_a$data_a))))
#   xmax <- max(as.numeric(as.character(data$data)))
#   plot(as.vector(data$data), as.vector(data$Freq), pch=17, xlim=c(xmin, xmax), xlab=paste0("Counts for ", var), ylab='Freq')
#   points(as.vector(data_t$data), as.vector(data_t$Freq), pch=19, col="blue")
#   points(as.vector(data_a$data), as.vector(data_a$Freq), pch=15, col="red")
# }

#for Table 3
sub_df   <- df[df$chlor_a>=16, ]
sub_df_a <- df_a[df_a$chlor_a>=8, ]
sub_df_t <- df_t[df_t$chlor_a>=8, ]
ratio[count, 1] = yr
ratio[count, 2] = nrow(df_a)
ratio[count, 3] = nrow(sub_df_a)
ratio[count, 4] = nrow(sub_df_t)
ratio[count, 5] = nrow(sub_df)
count <- count + 1

# for table 4 and 5
ar <- df_a[,17:24]
mat_a <- func1(ar, 1)
ar <- df_t[,17:24]
mat_t <- func1(ar, 1)
ar <- df[,17:24]
mat   <- func1(ar, 2)
mat_a <- mat_a[order(mat_a$Value),]
mat_t <- mat_t[order(mat_t$Value),]

func1 <- function(df, base) {
  mat <- data.frame(matrix(nrow=0, ncol=2))
  counts <- df
  counts[counts<base]  <- 0
  counts[counts>=base] <- 1
  for (i in c(1:8)){
    combs <- combn(8, i)
    for (j in c(1:ncol(combs))) {
      sub_counts <- data.frame(counts[,combs[,j]])
      rs <- rowSums(sub_counts)
      rs[rs< ncol(sub_counts)] <- 0
      rs[rs>=ncol(sub_counts)] <- 1
      value <- sum(rs)
      name  <- paste(as.character(combs[,j]), collapse = '')
      mat[nrow(mat) + 1,] <- c(name, value)
    }
  }
  colnames(mat) <- c('Name', 'Value')
  return(mat)
}


#Proportion of <=2 and >2 mg/L DO
yr <- 2003

stats <- data.frame(matrix(ncol=3, nrow=length(stations)))
colnames(stats) <- c('Year', 'Total', 'Hypoxia')
count <- 1
for (file in stations) {
  yr <- as.numeric(substr(file, 1, 4))
  df_year <- read.csv(paste0('./Data/hypoxia_watch_GOM_csv/', file), stringsAsFactors=FALSE)
  colnames(df_year) <- toupper(colnames(df_year))
  oxy <- df_year$OXMGL
  oxy[oxy<=2] = 0
  oxy[oxy> 2] = 1
  stats[count, 1] <- yr
  stats[count, 2] <- nrow(df_year)
  stats[count, 3] <- nrow(df_year) - sum(oxy)
  count <- count + 1
}

