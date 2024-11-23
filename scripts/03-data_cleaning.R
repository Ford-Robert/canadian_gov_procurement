#### Preamble ####
# Purpose: Cleans combined raw data set
# Author: Robert Ford
# Date: 22 November 2024
# Contact: robert.ford@mail.utoronto.ca
# License: MIT


#### Workspace setup ####
library(tidyverse)

#### Clean data ####
combined <- read_csv("data/raw_data/combined_data.csv")

# Step 1: Create a copy of the original dataframe
cleaned <- combined

# Step 2: Convert 'amount' to numeric in the 'cleaned' dataframe
cleaned$amount <- as.numeric(gsub("[\\$,]", "", cleaned$amount))

# Step 3: Remove any periods from the date strings
cleaned$award_date <- gsub("\\.", "", cleaned$award_date)
cleaned$start_date <- gsub("\\.", "", cleaned$start_date)
cleaned$end_date <- gsub("\\.", "", cleaned$end_date)

# Step 4: Convert date columns to Date objects
# Define the date format without the period
date_format <- "%b %d, %Y"

# Convert 'award_date' to Date
cleaned$award_date <- as.Date(cleaned$award_date, format = date_format)

# Convert 'start_date' to Date
cleaned$start_date <- as.Date(cleaned$start_date, format = date_format)

# Convert 'end_date' to Date
cleaned$end_date <- as.Date(cleaned$end_date, format = date_format)


View(cleaned)


#### Save data ####
write_csv(cleaned, "data/analysis_data/cleaned_data.csv")
