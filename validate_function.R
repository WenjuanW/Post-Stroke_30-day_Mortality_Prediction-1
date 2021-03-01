##############
# Title: validation function for externally validate other datasets
# Author: Wenjuan Wang

# Input the validation_sample.csv dataset, 
# Output the performace of the pretrained models on the validation dataset
# The output is a list including Brier Score, AUC, calibration plots, 
# calibration-in-the-large, calibration slope, 95% confidence interval of the above and decision curve analysis 


# libraries needed
library(tidyr)
install.packages("lifecycle", type = "source")

# Load validation dataset ------------------------
validation_dataset <- read_csv(file="validation_sample.csv")   # the dataset that one wants to externally validate

# Load pre-trained models --------------------------------
xgboost_model <- readRDS("xgboost_model.RDS")

# Confirm that validation dataset contains required features/outcomes 



# externally validate each model ---------------------------
# predict on the validation dateset

validation_dataset_xgb <- validation_dataset
validation_dataset_xgb$mortality_30_day %<>% as.factor()

testtask <- makeClassifTask(data = as.data.frame(validation_dataset_xgb),target = "mortality_30_day")

prob_xgb <- predict(xgboost_model,testtask, type = "prob")
roc_xgb <- roc(validation_dataset_xgb$mortality_30_day ~ prob_xgb$data$prob.1, plot = FALSE, print.auc = TRUE)
as.numeric(roc_xgb$auc)
ci.auc(validation_dataset_xgb$mortality_30_day, prob_xgb$data$prob.1) 

# Brier score, calibration-in-the-large and calibration slope

# Calibration plot

# Decision curve analysis

