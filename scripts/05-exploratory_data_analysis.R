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
View(df)

u_dsupps <- df %>%
  filter(buyer == "National Defence", amount >= 100000) %>%
  group_by(supplier) %>%
  summarize(total_amount = sum(amount, na.rm = TRUE), .groups = "drop")

# Display the unique suppliers
View(u_dsupps)

u_contracts <- data.frame(unique(df$contract))

max.print(u_contracts)

u_buyers <- data.frame(unique(df$buyer))

u_supps <- data.frame(unique(df$supplier))

View(u_supps)

public_health <- df[df$buyer == "Public Health Agency of Canada", ]

View(public_health)

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

space_total <- df %>%
  filter(buyer == "Canadian Space Agency") %>%
  summarize(total_amount = sum(amount, na.rm = TRUE)) %>%
  pull(total_amount)

print(space_total)

print(2199059594/ space_total)


View(contracts_expiring)
View(public_health)
View(defence)
