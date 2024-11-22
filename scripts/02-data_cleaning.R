#### Preamble ####
# Purpose: Cleans the raw plane data recorded by two observers..... [...UPDATE THIS...]
# Author: Rohan Alexander [...UPDATE THIS...]
# Date: 6 April 2023 [...UPDATE THIS...]
# Contact: rohan.alexander@utoronto.ca [...UPDATE THIS...]
# License: MIT
# Pre-requisites: [...UPDATE THIS...]
# Any other information needed? [...UPDATE THIS...]


#### Workspace setup ####
library(tidyverse)

#### Clean data ####
combined <- read_csv("data/raw_data/combined_data.csv")
# Assuming your original dataframe is named 'df'

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

# Optional: View the cleaned dataframe
print(cleaned)

#### Save data ####
write_csv(cleaned_data, "outputs/data/analysis_data.csv")
