rm(list=ls())

library(lme4)
library(lmerTest)
library(R.matlab)
library(reshape2)
library(rstatix)
library(dplyr)
library(plyr)

####AUC####
auc =read.csv("AUC Summary.csv")
auc = melt(auc, id.vars = "PID", value.name = "AUC", variable.name = "Function") 

auc$Function = revalue(auc$Function, c("LINEAR"="Lin", "CONVEX"="CU","CONCAVE"="CD" ))
auc$Function = factor(auc$Function, levels = c("Lin","CD","CU"))
# levels(auc$Function)

round(mean(auc$AUC),2)
round(sd(auc$AUC),2)

detach(package:plyr)
auc %>% group_by(Function) %>% summarise(mu = mean(AUC), sigma = sd(AUC)) %>%
mutate_if(is.numeric, format, 1)

# auc %>% group_by(Function) %>% identify_outliers(AUC)
# auc %>% group_by(Function) %>% shapiro_test(AUC)

hlmAUC = lmer(AUC ~ Function + (1|PID), data=auc)
summary(hlmAUC)

K23 <- matrix(c(0, -1, 1), 1)
t23 <- glht(hlmAUC, linfct = K23)
summary(t23)

-2.28-1.96*(0.49)
-2.28+1.96*(0.49)

2.25-1.96*(0.49)
2.25+1.96*(0.49)

4.52-1.96*(0.49)
4.52+1.96*(0.49)


####Clicks####

filePaths <- list.files(".\\Processed Experiment Data", full.names = T)
masterdata <- do.call(rbind, lapply(filePaths, read.csv))

masterdata$Function = factor(masterdata$Function)
levels(masterdata$Function) =  c("Lin", "CD", "CU") #Reversed from Matlab coding

shaping.box = boxplot(ResponseTime ~ Function, masterdata)

round(mean(masterdata$ResponseTime),2)
round(sd(masterdata$ResponseTime),2)

masterdata %>% group_by(Function) %>% 
  summarise(mu = mean(ResponseTime), sigma = sd(ResponseTime)) %>%
  mutate_if(is.numeric, format, 1)

#1 Linear 2 Convex(Concave UP) 3 Concave(Concave DOWN)

shaping.model = lmer(ResponseTime ~ Function + (1|PID) + (1|Trial), data=masterdata)
summary(shaping.model)

K23 <- matrix(c(0, -1, 1), 1)
t23 <- glht(shaping.model, linfct = K23)
summary(t23)

1.76-1.96*(0.49)
1.76+1.96*(0.49)

-2.29-1.96*(0.48)
-2.29+1.96*(0.48)

-4.05-1.96*(0.49)
-4.05+1.96*(0.49)


