#### Preamble ####
# Purpose: Models the 5 biggest Buyers and Other(rest of the Buyers)
# Author: Robert Ford
# Date: 28 November 2024
# Contact: robert.ford@mail.utoronto.ca
# License: MIT
# Pre-requisites: 
# - The `tidyverse` package must be installed and loaded
# - The `dplyr` package must be installed and loaded
# - The `car` package must be installed and loaded
# - The `caret` package must be installed and loaded
# Other information? Make sure you are in the `canadian_gov_procurement` rproj



#### Workspace setup ####
library(tidyverse)
library(dplyr)
library(car)
library(caret)

#### Read data ####
df <- read_csv("data/analysis_data/cleaned_data.csv")


### Model data ####

# Fit the models using baseline_days
model <- lm(amount ~ baseline_days + duration_days, data = df %>% filter(buyer != "National Defence"))

mil_model <- lm(amount ~ baseline_days + duration_days, data = df %>% filter(buyer == "National Defence"))

model_summary <- summary(model)
mil_model_summ <- summary(mil_model)

print(model_summary)
print(mil_model_summ)

#This plot helps check for non-linearity, unequal error variances (heteroscedasticity), and outliers.
# Residuals vs Fitted for full model
plot(model, which = 1)

# Residuals vs Fitted for National Defence model
plot(mil_model, which = 1)


#Assess whether the residuals are normally distributed.
# Q-Q Plot for full model
plot(model, which = 2)

# Q-Q Plot for National Defence model
plot(mil_model, which = 2)

#Checks the homoscedasticity (constant variance) of residuals
# Scale-Location Plot for full model
plot(model, which = 3)

# Scale-Location Plot for National Defence model
plot(mil_model, which = 3)

#Identifies influential observations that might unduly affect the model
# Residuals vs Leverage for full model
plot(model, which = 5)

# Residuals vs Leverage for National Defence model
plot(mil_model, which = 5)

#Use the Variance Inflation Factor (VIF) to detect multicollinearity 
#among predictors. VIF values greater than 5 or 10 indicate problematic multicollinearity.
# Install and load the 'car' package if not already installed

# VIF for full model
vif(model)

# VIF for National Defence model
vif(mil_model)


#Identify influential data points using Cook's Distance.
# Cook's Distance for full model
plot(model, which = 4)

# Identify observations with Cook's Distance > 4/(n - k - 1)
n <- nrow(df)
k <- length(coef(model)) - 1
cooks_threshold <- 4 / (n - k - 1)
influential_full <- which(cooks.distance(model) > cooks_threshold)
length(influential_full)

# Cook's Distance for National Defence model
plot(mil_model, which = 4)

n_mil <- nrow(df %>% filter(buyer == "National Defence"))
k_mil <- length(coef(mil_model)) - 1
cooks_threshold_mil <- 4 / (n_mil - k_mil - 1)
influential_mil <- which(cooks.distance(mil_model) > cooks_threshold_mil)
length(influential_mil)



#### Save model ####
saveRDS(model, file = "models/gen_model.rds")

saveRDS(mil_model, file = "models/mil_model.rds")

