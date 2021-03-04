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



### function for calculating Brier Score, AUC, Calibraiton-in-the-large and calibration slope with 95% Confidence Interval
### Input: Predicted probability (pred_prob) and True binary outcome (y)

performance_function <- function(pred_prob,y){
  

  # AUC and 95% CI
  roc <- roc(y ~ pred_prob, plot = FALSE, print.auc = TRUE)
  AUC <- as.numeric(roc$auc)
  AUC_95CI <- ci.auc(y, pred_prob) 
  AUC_and_95CI <- paste( round(AUC,3), ' (', round(AUC_95CI[1],3),'to',round(AUC_95CI[3],3),')')
  
  
  
  # Brier score, calibration-in-the-large and calibration slope and 95% confidence interval
  
  # calibration plot, Brier score, calibration-in-the-large and calibration slope
  res <- val.prob(pred_prob, as.numeric(y))
  
  
  # Bootstrapping different samples
  data_bootstrap <- cbind(pred_prob, y)
  boot_val <- boot_val(data_bootstrap)
  
  # Brier Score and 95% CI 
  brier <- round(res['Brier'],3) 
  brier_boot <- unlist(map(boot_val, `[`, c("Brier"))) %>% as.numeric()    
  brier_boot_ci <- calc_ci("Brier",   boot_val, 3)
  brier_and_95CI <- paste( brier, brier_boot_ci)
  
  
  # Calibration-in-the-large and 95% CI
  calibration_in_the_large <- round( res['Intercept'],3)
  intercept_boot_ci <- calc_ci("Intercept", boot_val, 3)
  intercept_and_95CI <- paste(calibration_in_the_large, intercept_boot_ci)
  
  # Calibration slope and 95% CI
  calibration_slope <- round(res['Slope'],3) 
  slope_boot_ci <- calc_ci("Slope",   boot_val, 3)
  slope_and_95CI <- paste(calibration_slope, slope_boot_ci)

    
  performance_List <- list("AUC" = AUC_and_95CI, "Brier" = brier_and_95CI, "Calibration-in-the-large" = intercept_and_95CI, "Calibration-Slope" = slope_and_95CI)
  return(performance_List)

  
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
LR_elasticnet_int_model <- readRDS("LR_elasticnet_interaction_pretrained_model.RDS")


# externally validate each model -----------------------------------------------

# predict on the validation dateset with XGBoost
validation_dataset_xgboost <- validation_dataset
validation_dataset_xgboost$mortality_30_day <- validation_dataset_xgboost$mortality_30_day %>% as.factor()
testtask <- makeClassifTask(data = as.data.frame(validation_dataset_xgboost),target = "mortality_30_day")
prob_xgboost <- predict(xgboost_model,testtask, type = "prob")

xgboost_performance <- performance_function(prob_xgboost$data$prob.1, validation_dataset$mortality_30_day)


# predict on the validation dateset with LR with elastic net and interaction terms
validation_interaction <- model.matrix(mortality_30_day ~.^2, validation_dataset)[,-1]
prob_LR_elasnet_int <- LR_elasticnet_int_model %>% predict(newdata = validation_interaction, type = "prob")

LR_elasticnet_ineraction_performance <- performance_function(prob_LR_elasnet_int$`1`, validation_dataset$mortality_30_day)


###print the results--------------------------------------------------------------
print(xgboost_performance)
print(LR_elasticnet_ineraction_performance)


### calibration plots----------------------------------------

# XGBoost
val.prob(prob_xgboost$data$prob.1, as.numeric(validation_dataset$mortality_30_day))
# Right LR with elastic net and interaction terms
val.prob(prob_LR_elasnet_int$`1`, as.numeric(validation_dataset$mortality_30_day))



plot.new()

# Decision curve analysis
netBenefit_xgboost <- netBenefit(prob_xgboost$data$prob.1,validation_dataset$mortality_30_day )
netBenefit_LR_elasticnet_interaction <- netBenefit(prob_LR_elasnet_int$`1`,validation_dataset$mortality_30_day )
FPrate <- length(which(validation_dataset$mortality_30_day==0))/length(validation_dataset$mortality_30_day)
FPrate_test <- netBenefit_all(FPrate,1:100)

plot(netBenefit_xgboost,type="l",col="blue",ylim = c(-0.2,0.6),lty=1,xlab = "Threshold probability in %",ylab = "Net Benefit")
lines(netBenefit_LR_elasticnet_interaction, col="red",lty=1)
lines(FPrate_test,lty=3)
abline(h=0, col="blue")
legend(50,0.53, legend=c("XGBoost","LR with elastic net and interaction terms","Treating all","Y = 0, Treating none"),
       col=c("blue", "red","black","blue"),lty = c(1,1,3,1),cex = 0.75)

