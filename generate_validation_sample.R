# Objective: Generate a ramdon validation dataset according to how the real dataset look like
# Author Wenjuan Wang



# n is the number of cases/patients that one wants to generate
n = 2000

Age_Groups_by5 <- array(sample(21, n, replace = TRUE)) -1
Male <- array(sample(c(0,1), n, replace = TRUE)) 

#Generate a one hot encoding matrix of 6 category for ethnicity
M_ethnicity <- matrix(0,n,6)
M_ethnicity[cbind(1:n, sample(1:6, 6, rep=TRUE))] <- 1

Ethnicity.Black <- M_ethnicity[,1]
Ethnicity.Mixed <- M_ethnicity[,2]
Ethnicity.Other <- M_ethnicity[,3]
Ethnicity.Unknown <- M_ethnicity[,4]
Ethnicity.White <- M_ethnicity[,5]

Inpatient_at_time_of_stroke <- array(sample(c(0,1), n, replace = TRUE)) 

#Generate a one hot encoding matrix of 6 category for hour of admission
M_hour <- matrix(0,n,6)
M_hour[cbind(1:n, sample(1:6, 6, rep=TRUE))] <- 1

hour_of_admission_4h_band.04.00.00.to.07.59.59 <- M_hour[,1] 
hour_of_admission_4h_band.08.00.00.to.11.59.59 <- M_hour[,2]
hour_of_admission_4h_band.12.00.00.to.15.59.59 <- M_hour[,3]
hour_of_admission_4h_band.16.00.00.to.19.59.59 <- M_hour[,4]
hour_of_admission_4h_band.20.00.00.to.23.59.59 <- M_hour[,6]

#Generate a one hot encoding matrix of 6 category for day of admission
M_day <- matrix(0,n,7)
M_day[cbind(1:n, sample(1:7, 7, rep=TRUE))] <- 1

day_of_week_of_admission.Monday   <- M_day[,1]
day_of_week_of_admission.Saturday    <- M_day[,2]
day_of_week_of_admission.Sunday    <- M_day[,3]
day_of_week_of_admission.Thursday   <- M_day[,4]
day_of_week_of_admission.Tuesday    <- M_day[,5]
day_of_week_of_admission.Wednesday   <- M_day[,6]


congestive_heart_failure <- array(sample(c(0,1), n, replace = TRUE)) 
hypertension <- array(sample(c(0,1), n, replace = TRUE)) 
atrial_fibrillation <- array(sample(c(0,1), n, replace = TRUE)) 
diabetes <- array(sample(c(0,1), n, replace = TRUE)) 
previous_stroke_tia <- array(sample(c(0,1), n, replace = TRUE)) 

#Generate a one hot encoding matrix of 6 category for day of admission
M_anticoagulation <- matrix(0,n,4)
M_anticoagulation[cbind(1:n, sample(1:4, 4, rep=TRUE))] <- 1

prior_anticoagulation_if_Afib.No.but <- M_anticoagulation[,1]
prior_anticoagulation_if_Afib.Unknown <- M_anticoagulation[,2]
prior_anticoagulation_if_Afib.Yes <- M_anticoagulation[,3]


rankin_scale_prestroke <- array(sample(6, n, replace = TRUE)) - 1


nihss_loss_of_consciousness   <- array(sample(4, n, replace = TRUE)) - 1 
nihss_answers_questions   <- array(sample(3, n, replace = TRUE)) - 1     
nihss_obeys_commands     <- array(sample(3, n, replace = TRUE)) - 1  
nihss_best_gaze          <- array(sample(3, n, replace = TRUE)) - 1  
nihss_visual_deficits    <- array(sample(4, n, replace = TRUE)) - 1  
nihss_facial_weakness     <- array(sample(4, n, replace = TRUE)) - 1  
nihss_left_arm_weakness     <- array(sample(5, n, replace = TRUE)) - 1   
nihss_right_arm_weakness     <- array(sample(5, n, replace = TRUE)) - 1  
nihss_left_leg_weakness      <- array(sample(5, n, replace = TRUE)) - 1   
nihss_right_leg_weakness      <- array(sample(5, n, replace = TRUE)) - 1   
nihss_ataxia                 <- array(sample(3, n, replace = TRUE)) - 1  
nihss_sensory_loss            <- array(sample(4, n, replace = TRUE)) - 1 
nihss_best_language           <- array(sample(4, n, replace = TRUE)) - 1   
nihss_dysarthria               <- array(sample(3, n, replace = TRUE)) - 1   
nihss_extinction            <- array(sample(3, n, replace = TRUE)) - 1  

  
# nihss is the sum of all the subcomponents above
nihss_arrival <- rowSums(cbind(nihss_loss_of_consciousness,nihss_answers_questions,nihss_obeys_commands,
                         nihss_best_gaze,nihss_visual_deficits,nihss_facial_weakness,
                         nihss_left_arm_weakness,nihss_right_arm_weakness,nihss_ataxia,nihss_sensory_loss,
                         nihss_best_language,nihss_dysarthria, nihss_extinction))


#Generate a one hot encoding matrix of 6 category for type of stroke
M_typestroke <- matrix(0,n,3)
M_typestroke[cbind(1:n, sample(1:3, 3, rep=TRUE))] <- 1

type_of_stroke.Primary.Intracerebral.Haemorrhage <- M_typestroke[,1] 
type_of_stroke.Uknown  <- M_typestroke[,2] 


mortality_30_day <- array(sample(c(0,1), n, replace = TRUE)) 


validation_sample <- cbind(Age_Groups_by5, Male,
                           Ethnicity.Black,Ethnicity.Mixed,Ethnicity.Other,Ethnicity.Unknown,Ethnicity.White,
                           hour_of_admission_4h_band.04.00.00.to.07.59.59,hour_of_admission_4h_band.08.00.00.to.11.59.59,hour_of_admission_4h_band.12.00.00.to.15.59.59,
                           hour_of_admission_4h_band.16.00.00.to.19.59.59,hour_of_admission_4h_band.20.00.00.to.23.59.59,
                           day_of_week_of_admission.Monday,day_of_week_of_admission.Saturday,day_of_week_of_admission.Sunday,
                           day_of_week_of_admission.Thursday,day_of_week_of_admission.Tuesday,day_of_week_of_admission.Wednesday,
                           congestive_heart_failure,hypertension,atrial_fibrillation,diabetes,previous_stroke_tia,
                           prior_anticoagulation_if_Afib.No.but,prior_anticoagulation_if_Afib.Unknown,prior_anticoagulation_if_Afib.Yes,
                           rankin_scale_prestroke,
                           nihss_arrival,nihss_loss_of_consciousness,
                           nihss_answers_questions,nihss_obeys_commands,nihss_best_gaze,nihss_visual_deficits,nihss_facial_weakness,
                           nihss_left_arm_weakness,nihss_right_arm_weakness,nihss_left_leg_weakness,nihss_right_leg_weakness,
                           nihss_ataxia,nihss_sensory_loss,nihss_best_language,nihss_dysarthria,nihss_extinction,
                           type_of_stroke.Primary.Intracerebral.Haemorrhage,type_of_stroke.Uknown,mortality_30_day)


write.csv(validation_sample,"validation_sample")
