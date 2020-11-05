library(randomForest)

# setwd("C:/Users/Ho Yi/Desktop/working papers/telecoupling/deadzone/data")
# 
# load("C:/Users/Ho Yi/Desktop/working papers/telecoupling/deadzone/data/data_2015_aqua__by1w_long.RData")
# df1 <- data15_1w_windows
# 
# load("C:/Users/Ho Yi/Desktop/working papers/telecoupling/deadzone/data/data_2015_aqua__by1w_wide.RData")
# df2 <- data15_1w_windows_wide
# write.csv(df2, "aqua.csv", row.names = F)
# 
# load("C:/Users/Ho Yi/Desktop/working papers/telecoupling/deadzone/data/data_2015_terr__by1w_long.RData")
# df3 <- data15_1w_windows
# 
# load("C:/Users/Ho Yi/Desktop/working papers/telecoupling/deadzone/data/data_2015_terr__by1w_wide.RData")
# df4 <- data15_1w_windows_wide
# using aqua_wide for testing
# df <- read.csv("aqua.csv")

############################################################################# #
############################################################################# #
# set work dir
path <- rstudioapi::getSourceEditorContext()$path
dir  <- dirname(rstudioapi::getSourceEditorContext()$path); dir
setwd(dir)
getwd()
list.files(path = './Img2Table', full.names = T)

load("./Img2Table/data_2015_aqua__by1w_wide.RData")
# df <- data15_1w_windows_wide

write.csv(df2, "aqua.csv", row.names = F)
df <- read.csv("aqua.csv")

### aggregate by the mean value of all the bands for each station
xmean <- aggregate(df[, 7:ncol(df)], by=list(df$station), FUN=mean, na.rm=T)
### aggregate by the mean value of the ox data for each station
ymean <- aggregate(df$oxmgl, by=list(df$station), FUN=mean, na.rm=T)

xvar <- xmean[,-1] ## remove the column of station id 
yvar <- ymean[,-1]

rf.data <- cbind(yvar, xvar) ## put y and x(s) in one table 
str(rf.data)

### run rf model
rf.fit <- randomForest(yvar ~ ., data = rf.data, ntree=99, 
                       importance=TRUE, norm.votes=TRUE, 
                       proximity=TRUE, na.action=na.roughfix)

rf.fit
attributes(rf.fit)

plot(rf.fit)

# Variable Importance
varImpPlot(rf.fit,  
           sort = T,
           n.var=10,
           main="Top 10 - Variable Importance")

dev.off()




# na.omit
rf.na.omit.data <- na.omit(rf.data)

rf.fit2 <- randomForest(yvar ~ ., data = rf.na.omit.data, ntree=99, 
                       importance=TRUE, norm.votes=TRUE, 
                       proximity=TRUE)

rf.fit2



######## tune RF ###########
# tuning with mtry
dev.off()
tune_RF <- tuneRF(x = rf.na.omit.data[,-1], y = rf.na.omit.data[,1], 
                  # stepFactor = 0.1, # at each iteration, mtry is inflated (or deflated) by this value
                  plot = T, # whether to plot the OOB error as function of mtry
                  ntreeTry = 100, # number of trees used at the tuning step, because:
                  # according "plot(rf)" 500 trees are not necessary since the error is stable after 100 trees
                  trace=T, # whether to print the progress of the search
                  improve = 0.005)  # the (relative) improvement in OOB error must be by this much for the search to continue

print(tune_RF)
# mtry with smallest error should be used for train RF
# in this case mtry = 3 is already the best choice

# AFTER TUNING, best choice would be:
rf <- randomForest(yvar ~ .,
                   data  = rf.na.omit.data,
                   ntree = 100, 
                   importance=TRUE, norm.votes=TRUE, proximity=TRUE, 
                   mtry  = 14)

######## histogram #########
# number of nodes in the tree
hist(treesize(rf),
     main ="number of nodes in the tree",
     col="green")
plot(rf)
#################################################

imp <- rf.fit2$importance

imp

impvar <- rownames(imp); impvar

op <- par(mfrow=c(2, 3))
for (i in seq_along(impvar)) {
  partialPlot(rf.fit2, rf.na.omit.data, impvar[i], xlab=impvar[i],
              main=paste(impvar[i]),
              )
}
par(op)
