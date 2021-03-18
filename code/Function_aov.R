
### Function for Tukeys post-hoc on ggplot boxplot
library(tidyverse)
library(multcompView)
library(lsmeans)
library(multcomp)



function_aov <- function(data){
  
  ## a function to generate letter labels
  generate_label_df <- function(TUKEY, variable){
    # Extract labels and factor levels from Tukey post-hoc 
    Tukey.levels <- TUKEY[[variable]][,4]
    Tukey.labels <- data.frame(multcompLetters(Tukey.levels)['Letters'])
    # I need to put the labels in the same order as in the boxplot :
    Tukey.labels$treatment=rownames(Tukey.labels)
    Tukey.labels=Tukey.labels[order(Tukey.labels$treatment) , ]
    return(Tukey.labels)
  }
  
  data$group <- factor(data$group, levels = unique(data$group))
  model <- lm(value ~ group, data = data)
  ANOVA <- aov(model)
  
  # Tukey test to study each pair of treatment :
  TUKEY <- TukeyHSD(x=ANOVA, conf.level = 0.95)
  
  #generate labels using function
  labels <- generate_label_df(TUKEY , variable = "group")
  
  names(labels) <- c('Letters','group')#rename columns for merging
  
  ## obtain letter position for y axis using means
  # yvalue <- aggregate(value~group, data=data, FUN = mean) 
  yvalue <- aggregate(value~group, data=data, FUN = 'quantile', probs=0.75) ## 
  final <- merge(labels, yvalue) #merge dataframes
  
  return(final)
}




### test code
# data <- df
# str(df)
# function_aov(data = df)


# df.chg <- df %>% mutate(value = change)
# data <- df.chg
# final$Letters
# as.character(final$Letters)
# # install.packages("stringr", dependencies=TRUE)
# require(stringr)
# str_trim(final$Letters)
