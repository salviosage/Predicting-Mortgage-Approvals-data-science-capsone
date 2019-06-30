
#Setting up the working directory

setwd('C:/Users/IRENEE/Desktop/Data Science')

# Importing libraries

options(max.print = 1000, scipen = 999, width = 90)
library(dplyr)
options(dplyr.print_max = 2000)
options(dplyr.width = Inf) # Shows all columns of tbl_df object
library(stringr)
library(lubridate)
library(rgeos) # spatial package
library(sp) # spatial package
library(maptools) #spatial package
library(ggmap)
library(ggplot2)
library(gridExtra) # For putting plots side by side
library(ggrepel) # avoid text overlap in plots
library(tidyr)
library(seriation) # package for reordering a distance matrix
library(repr)
library(caret)
library(ROCR)
library(pROC)
library(SuperLearner)
library(ranger)
library(kernlab)
library(party)

# Importing datasets

training_Values <- read.csv('DAT102x_Predicting_Mortgage_Approvals_From_Government_Data_-_Training_inputs.csv')
test_values <- read.csv('DAT102x_Predicting_Mortgage_Approvals_From_Government_Data_-_Test_values.csv')
training_labels <- read.csv('DAT102x_Predicting_Mortgage_Approvals_From_Government_Data_-_Training_labels.csv')

# Factor variables

cat.names <- c('msa_md', 'state_code', 'county_code', 'lender', 'loan_type', 'property_type', 'loan_purpose', 'occupancy', 'preapproval', 'applicant_ethnicity', 'applicant_race', 'applicant_sex')
bool.names <- c('accepted', 'co_applicant')
num.names <- c('loan_amount', 'applicant_income', 'population', 'minority_population_pct', 'ffiecmedian_family_income', 'tract_to_msa_md_income_pct', 'number_of_owner.occupied_units', 'number_of_1_to_4_family_units')

# converting categorical variables into factors 

training_Values[, cat.names] = data.frame(apply(training_Values[cat.names], 2, as.factor)) #using apply
training_Values[, cat.names] = lapply(training_Values[, cat.names], as.factor) #using lapply
training_Values[, cat.names] = data.frame(sapply(training_Values[, cat.names], as.factor)) #using Sapply


# scaling numrical variables

preProcValues <- preProcess(training_Values[,num.names], method = c("center", "scale"))
training_Values[, num.names] <- predict(preProcValues, training_Values[, num.names])

# Checking structure of training values dataset

str(training_Values)

#dealing with missing values

# Now missing variables are replaced by median (training data)

training_Values$applicant_income[is.na(training_Values$applicant_income)] <- median(training_Values$applicant_income, na.rm = TRUE)
training_Values$population[is.na(training_Values$population)] <- median(training_Values$population, na.rm = TRUE)
training_Values$minority_population_pct[is.na(training_Values$minority_population_pct)] <- median(training_Values$minority_population_pct, na.rm = TRUE)
training_Values$ffiecmedian_family_income[is.na(training_Values$ffiecmedian_family_income)] <- median(training_Values$ffiecmedian_family_income, na.rm = TRUE)
training_Values$tract_to_msa_md_income_pct[is.na(training_Values$tract_to_msa_md_income_pct)] <- median(training_Values$tract_to_msa_md_income_pct, na.rm = TRUE)
training_Values$number_of_owner.occupied_units[is.na(training_Values$number_of_owner.occupied_units)] <- median(training_Values$number_of_owner.occupied_units, na.rm = TRUE)
training_Values$number_of_1_to_4_family_units[is.na(training_Values$number_of_1_to_4_family_units)] <- median(training_Values$number_of_1_to_4_family_units, na.rm = TRUE)

sum(is.na(training_Values))




# Ensemble model

set.seed(150)

# Fit the ensemble model
model_all <- SuperLearner(training_labels$accepted,
                          training_Values,
                          family = binomial(),
                          SL.library = list("SL.ranger",
                                            "SL.ksvm",
                                            "SL.ipredbagg",
                                            "SL.bayesglm"))

# Return the model
model_all

# Predict test prob using super learner 

test_values$prob <- predict.SuperLearner(model_all, newdata = test_values)

