###################################
# Title: validation function for externally validate other datasets
# Author: Wenjuan Wang

# Input the validation_sample.csv dataset, 
# Output the performace of the pretrained models on the validation dataset
# The output is a list including Brier Score, AUC, calibration plots, 
# calibration-in-the-large, calibration slope, 95% confidence interval of the above and decision curve analysis 
####################################

# libraries needed------------------------------------------------------
library(tidyr)
library(purrr)
library(dplyr)
library(rms)
library(caret)
library(readr)
library(xgboost)
library(mlr)
library(pROC)
library(e1071)


# Functions needed-------------------------------------------------------

### functions for calculating 95% confidence interval by bootstrapping
boot_val <- function(data){
  set.seed(48572)
  out <- list()
  data <- as.data.frame(data)
  for(i in 1:500){
    df <- sample_n(data, nrow(data), replace = TRUE)
    out[[i]] <- val.prob(df[,1],df[,2])
  }
  return(out)
}


calc_ci <- function(metric, boot_vals, n){
  x <- unlist(map(boot_vals, `[`, c(metric)))
  paste0("(", round(quantile(x, 0.025), n), " to ", 
         round(quantile(x, 0.975), n), ")")
}

### functions for calculating net benefit for decision curve analysis

netBenefit <- function(predProb, trueClass){
  
  netBenefit <- matrix(0,nrow = 100,ncol = 1)
  
  for (i in 1:100) {
    pt <- i*0.01
    predClass <-  ifelse(predProb >= pt, 1,0)
    pred <- factor(predClass,levels = c(0,1))
    
    truth <- factor(trueClass,levels = c(0,1))
    
    confuMatrix <- confusionMatrix(pred,truth)
    a <- confuMatrix$table[2,2]/length(predClass)    # true positive count/n total number = Detection Rate
    b <-  confuMatrix$table[2,1]/length(predClass)   # false positive count/n total number = Detection prevalence - detection rate
    netBenefit[i] <- a - b*pt/(1-pt)
  }
  
  return(netBenefit)
  
}

# net benefit for treating all
netBenefit_all <- function(FPrate,pt){
  1 - FPrate/(1-pt*0.01)
}



# Load validation dataset ------------------------------------------------------
validation_dataset <- read.csv(file="validation_sample.csv")[,-1]   # the dataset that one wants to externally validate

# Load pre-trained models -----------------------------------------------------
xgboost_model <- readRDS("XGBoost_pretrained_model.RDS")


# externally validate each model -----------------------------------------------
# predict on the validation dateset

validation_dataset$mortality_30_day <- validation_dataset$mortality_30_day %>% as.factor()

testtask <- makeClassifTask(data = as.data.frame(validation_dataset),target = "mortality_30_day")
prob_xgb <- predict(xgboost_model,testtask, type = "prob")

# AUC and 95% CI
roc_xgb <- roc(validation_dataset$mortality_30_day ~ prob_xgb$data$prob.1, plot = FALSE, print.auc = TRUE)
AUC <- as.numeric(roc_xgb$auc)
AUC_95CI <- ci.auc(validation_dataset$mortality_30_day, prob_xgb$data$prob.1) 
AUC_and_95CI <- paste('The AUC and 95% Confidence Interval for XGBoost are:', round(AUC,3), ' (', round(AUC_95CI[1],3),'to',round(AUC_95CI[3],3),')')



# Brier score, calibration-in-the-large and calibration slope and 95% confidence interval

# calibration plot, Brier score, calibration-in-the-large and calibration slope
res_xgboost <- val.prob(prob_xgb$data$prob.1, as.numeric(validation_dataset$mortality_30_day))


# Bootstrapping different samples
data_bootstrap <- cbind(prob_xgb$data$prob.1, validation_dataset$mortality_30_day)
xgboost_val <- boot_val(data_bootstrap)

# Brier Score and 95% CI 
xgboost_brier <- round(res_xgboost['Brier'],3) 
xgboost_brier_boot <- unlist(map(xgboost_val, `[`, c("Brier"))) %>% as.numeric()    
xgboost_brier_boot_ci <- calc_ci("Brier",   xgboost_val, 3)
xgboost_brier_and_95CI <- paste('The Brier Score and 95% Confidence Interval for XGBoost are:', xgboost_brier, xgboost_brier_boot_ci)


# Calibration-in-the-large and 95% CI
xgboost_calibration_in_the_large <- round( res_xgboost['Intercept'],3)
xgboost_intercept_boot_ci <- calc_ci("Intercept",   xgboost_val, 3)
xgboost_intercept_and_95CI <- paste('The Calibration-in-the-large and 95% Confidence Interval for XGBoost are:', xgboost_calibration_in_the_large, xgboost_intercept_boot_ci)

# Calibration slope and 95% CI
xgboost_calibration_slope <- round(res_xgboost['Slope'],3) 
xgboost_slope_boot_ci <- calc_ci("Slope",   xgboost_val, 3)
xgboost_slope__and_95CI <- paste('The Calibration Slope and 95% Confidence Interval for XGBoost are:',xgboost_calibration_slope, xgboost_slope_boot_ci)


# Decision curve analysis

netBenefit_xgb <- netBenefit(prob_xgb$data$prob.1,validation_dataset$mortality_30_day )

FPrate <- length(which(validation_dataset$mortality_30_day==0))/length(validation_dataset$mortality_30_day)
FPrate_test <- netBenefit_all(FPrate,1:100)



###print the results---------------------------------------
print(xgboost_brier_and_95CI)
print(AUC_and_95CI)
print(xgboost_intercept_and_95CI)
print(xgboost_slope__and_95CI)


par(mfrow=c(1,2))
val.prob(prob_xgb$data$prob.1, as.numeric(validation_dataset$mortality_30_day))


plot(netBenefit_xgb,type="l",col="blue",ylim = c(-0.2,0.6),lty=1,xlab = "Threshold probability in %",ylab = "Net Benefit")
lines(FPrate_test,lty=3)
abline(h=0, col="blue")
legend(50,0.53, legend=c("XGBoost","Treating all","Y = 0, Treating none"),
       col=c("blue","black","blue"),lty = c(1,3,1),cex = 0.75)

