# Risk prediction of 30-day mortality after stroke using machine learning techniques: a nationwide registry-based cohort study

## Overview

* This repository provides pre-trained models for future studies to externally validate the trained models in a paper
* Please get in touch if you would like to collaborate on externally validate this post-stroke 30-day mortality prediction model
   + Email: wenjuan.wang@kcl.ac.uk
* If you use code/trained models from this repository, please cite the pre-print as a condition of use

## About the models

The file validation.R validates five models that were initially trained on SSNAP registry data in 2013-2018. The five models are: Logistic Regression (LR) reference model, LR, LR with elastic net, LR with elastic net and interaction terms, and XGBoost.

The script imports a validation dateset (validation.csv) and generates the following:

1. Evaluate discrimination (area under the ROC curve (AUC)) of the pre-trained models on the validation dataset;
2. Evaluate the Brier Score of the pre-trained models on the validation dataset;
3. Evaluate calibration (calibration-in-the-large, calibration slop and calibration plots) on the validation dataset;
4. Generate the decision curve with net benefit at every probability thresthold;
5. Export the above results in a file

Note:
* The code does not perform any training or cross-validation;
* Imputation was done with median/mean values of each variable (default values are from the training set of the original model due to the assumption that the data for validation are not known beforehand);

## How to use this repository

1. Prepare your validation dataset (named validation.csv) according to the below specification.
2. Run validation.R.
3. Email the resulting file to wenjuan.wang@kcl.ac.uk.

### Measures needed to validate these models

#### Outcomes

* The outcome is in-hospital 30-day mortality after stroke
* Each outcome is coded as 1 if the patient died within 30 days in hospital after stroke

In the SSNAP sample (n=358588), the event rate was: 12.4%

#### Required Variables

The 30 required variables, including the name, coding of the variables are listed below


| Variables/features         |  dataset column names | Measurements | Coding |
|:--------------|:---------------|:----------------------|:----------------- |
|         Age              | Age_Groups_by5              |      band by 5 from age 15 to age 125     |  levels: 0-20      |
|               Sex        | Male                        |   Female and Male                |   0-Female, 1-Male           |
|               Ethnicity   | Code as following       |   White, Black, Asian, Mixed, Other, Uknown           |   One hot encoding (Asian reference)|
|                         | Ethnicity.Black              |                                   |  Code 1 if Black |
|                         | Ethnicity.Mixed              |                               |   Code 1 if Mixed  |
|                         | Ethnicity.Other              |                               |    Code 1 if Other |
|                         | Ethnicity.Unknown              |                               |   Code 1 if Uknown |
|                         | Ethnicity.White              |                               |   Code 1, if White |
|Inpatient at time of stroke |Inpatient_at_time_of_stroke |         Yes or No                    | 0-No, 1-Yes            |
|Hour of admission   | Code as following                | 6 Levels, 4 hours band              | One hot encoding (00.00.00.to.03.59.59 as reference) |
|                    | hour_of_admission_4h_band.04.00.00.to.07.59.59          |               | Code 1 if in 04.00.00.to.07.59.59      |
|                   | hour_of_admission_4h_band.08.00.00.to.11.59.59           |               |   Code 1 if in 08.00.00.to.11.59.59      |
|                  | hour_of_admission_4h_band.12.00.00.to.15.59.59           |               |  Code 1 if in 12.00.00.to.15.59.59      |
|                  | hour_of_admission_4h_band.16.00.00.to.19.59.59           |               | Code 1 if in 16.00.00.to.19.59.59      |
|                  | hour_of_admission_4h_band.20.00.00.to.23.59.59           |               |  Code 1 if in 20.00.00.to.23.59.59      |
|Day of week of admission | Code as following      | Monday – Sunday             | One hot encoding (Sunday as reference)              |
|                 | day_of_week_of_admission.Monday      |              | Code 1 if Monday             |
|                 | day_of_week_of_admission.Saturday      |              | Code 1 if Saturday               |
|                 | day_of_week_of_admission.Sunday      |              | Code 1 if Sunday             |
|                 | day_of_week_of_admission.Thursday      |              | Code 1 if Thursday               |
|                 | day_of_week_of_admission.Tuesday      |              | Code 1 if Tuesday              |
|                 | day_of_week_of_admission.Wednesday      |              | Code 1 if Wednesday              |
|Congestive heart failure  | congestive_heart_failure     |     Yes or No                | 0-No, 1-Yes                   |
|hypertension             | hypertension                  |      Yes or No               | 0-No, 1-Yes                   |
|Atrial fibrillation (AF)  | atrial_fibrillation          |    Yes or No                  | 0-No, 1-Yes                  |
|diabetes                 | diabetes                      |      Yes or No                  | 0-No, 1-Yes                |
|Previous stroke/tia    | previous_stroke_tia           |   No,  Yes     | 0-No, 1-Yes          |
|Prior anticoagulation if AF*|     prior_anticoagulation_if_Afib |    No, No but, Unknown, Yes| One hot encoding (No as reference)      |
|    | prior_anticoagulation_if_Afib.No.but              |        | Code 1 if No but        |
|    | prior_anticoagulation_if_Afib.Unknown              |        | Code 1 if Unknown          |
|    | prior_anticoagulation_if_Afib.Yes              |        | Code 1 if Yes           |
|Modified Rankin Scale pre stroke| rankin_scale_prestroke  |                             | 0-5                         |
|level of consciousness|  nihss_loss_of_consciousness      |                                  | 0-3           |
|answers questions |  nihss_answers_questions             |                                | 0-2             |
|obeys commands    |  nihss_obeys_commands               |                           |      0-2              |
|best gaze         |  nihss_best_gaze                     |                           |        0-2              |
|visual deficits   |  nihss_visual_deficits              |                            |         0-3             |
|facial weakness   |  nihss_facial_weakness              |                          |              0-3          |
|left arm weakness |  nihss_left_arm_weakness            |                             |              0-4      |
|right arm weakness |  nihss_right_arm_weakness          |                            |             0-4         |
|left leg weakness |  nihss_left_leg_weakness            |                            |           0-4           |
|right leg weakness| nihss_right_leg_weakness            |                            |           0-4           |
|ataxia            |  nihss_ataxia                       |                            |           0-2            |
|sensory loss      |  nihss_sensory_loss                 |                            |              0-2        |
|best language     |  nihss_best_language                |                             |                0-3     |
|dysarthria        |  nihss_dysarthria                   |                            |               0-2       |
|extinction        |  nihss_extinction                   |                            |                  0-2     |
|NIHSS at arrival   |      nihss_arrival                   | Sum of imputed NIHSS components | 0-42                |
|Type of stroke    |  Code as following   |    Infarction, Primary Intracerebral Haemorrhage, Unknown |    One hot encoding (Infarction as reference)  |
|        |  type_of_stroke.Primary.Intracerebral.Haemorrhage   |    |  Code 1 if Primary Intracerebral Haemorrhage    |
|        |  type_of_stroke.Uknown                     |    |  Code 1 if Unknown   | 
|       30-day mortality   |  mortality_30_day            |    Died within 30 days(Yes and no)  |    0-No, 1-Yes           |


#### Important

* All variables/features must be measured within 24 hours after hospital admission
* All variable names and coding have to be exactly the same as the above table, indcluding the sequence


### Software enviornment

* Data cleaning and training were performed in R 3...
* Required packages are 
* For testing purposes, similated data was generated for validation data. These values are randomly generated and are not representative of the training dataset.
* To test all models on the simulated dataset, run:

### How to impute the Missing data in the validation dataset

* Missing data in the training set were imputed as the following:
   + New category for ....
   + MICE for NIHSS components and then NIHSS arrival was imputed by adding the NIHSS components
* Missing data in the validation set will use mean/median of the validation set (many cases) or default values from training set.








