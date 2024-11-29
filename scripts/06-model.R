#### Preamble ####
# Purpose: Models the 5 biggest Buyers and Other(rest of the Buyers)
# Author: Robert Ford
# Date: 28 November 2024
# Contact: robert.ford@mail.utoronto.ca
# License: MIT
# Pre-requisites: 
# - The `tidyverse` package must be installed and loaded
# - The `dplyr` package must be installed and loaded
# - 
# Other information? Make sure you are in the `canadian_gov_procurement` rproj



#### Workspace setup ####
library(tidyverse)
library(dplyr)

#### Read data ####
df <- read_csv("data/analysis_data/cleaned_data.csv")

#TODO Simplify Down to one model

### Model data ####
# Define the specific buyers
specific_buyers <- c(
  "National Defence",
  "Public Services and Procurement Canada",
  "Shared Services Canada",
  "Public Health Agency of Canada",
  "Fisheries and Oceans Canada"
)

# Create a new column 'buyer_group' categorizing each buyer
df <- df %>%
  mutate(
    buyer_group = ifelse(buyer %in% specific_buyers, buyer, "Other")
  )

df <- df %>%
  mutate(
    award_date_numeric = as.numeric(award_date)
  )

# Split the dataframe into a list of dataframes by 'buyer_group'
buyer_groups <- split(df, df$buyer_group)

# Initialize an empty list to store the models
models <- list()

# Loop through each buyer group and fit the linear model
for (buyer in names(buyer_groups)) {
  # Subset the data for the current buyer group
  data_subset <- buyer_groups[[buyer]]
  
  # Check if there are enough data points to fit a model
  if(nrow(data_subset) > 1) {  # At least two points needed for regression
    # Fit the linear model: amount ~ award_date_numeric + duration_days
    model <- lm(amount ~ award_date_numeric + duration_days, data = data_subset)
    
    # Store the model in the list with the buyer group name as the key
    models[[buyer]] <- model
  } else {
    warning(paste("Not enough data to fit a model for:", buyer))
  }
}


model_summaries <- lapply(models, summary)
print(model_summaries)




#### Save model ####
saveRDS(models, file = "models/buyer_models.rds")

