#### Preamble ####
# Purpose: EDA
# Author: Robert Ford
# Date: 23 November 2024
# Contact: robert.ford@mail.utoronto.ca
# License: MIT


#### Workspace setup ####
library(tidyverse)
library(rstanarm)

#### Read data ####
df <- read_csv("data/analysis_data/cleaned_data.csv")

u_supps <- data.frame(unique(df$supplier))

u_buyers <- data.frame(unique(df$buyer))

public_health <- df[df$buyer == "Public Health Agency of Canada", ]

defence <- df[df$buyer == "National Defence", ]

# Ensure 'amount' is numeric and 'end_date' is in Date format
df <- df %>%
  mutate(
    # Remove dollar signs and commas from 'amount' and convert to numeric
    amount = as.numeric(gsub("[$,]", "", amount)),
    # Convert 'end_date' to Date format (assuming format like "Aug. 21, 2024")
    end_date = as.Date(end_date, format = "%b. %d, %Y")
  )

# Group by 'end_date' and calculate the number of contracts and sum of amounts
contracts_expiring <- df %>%
  group_by(end_date) %>%
  summarise(
    number_of_contracts_expiring = n(),
    sum_of_amounts = sum(amount, na.rm = TRUE)
  ) %>%
  ungroup()

View(contracts_expiring)
View(public_health)
View(defence)
