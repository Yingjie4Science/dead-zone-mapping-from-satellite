
### last update: 2022-05-04
# today()


### test data
# r <- c('a', 'b', 'c')
# c <- c(1, 2, 3)
# yr <- 2000


### the function -------------------------------------------------------


function_format_rs_timeseries <- function(df, yr) {
  
  ## ***test data***
  # df <- d1
  
  ## get the YEID as rows
  r <- unique(df$YEID)
  
  ## get the date list as column names
  date_ini <- paste(yr, '03-01', sep = "-")
  date_end <- paste(yr, '09-30', sep = "-")
  c <- seq(as.Date(date_ini), as.Date(date_end), by = "1 day")
  
  ## create a matrix, and rename the rows with YEID, rename the columns as date
  m <- matrix(nrow = length(r), ncol = length(c))
  colnames(m)  <- as.character(c)
  row.names(m) <- as.character(r)
  
  ## convert the matrix to data frame, and then to a map between YEID and date, which will be used to format RS data
  df <- m %>% 
    as.data.frame() %>%
    tibble::rownames_to_column(var = 'YEID') %>%
    tidyr::gather(key = date_img, value = value, 2:ncol(.)) %>%
    dplyr::select(-value)
  
  return(df)
}
