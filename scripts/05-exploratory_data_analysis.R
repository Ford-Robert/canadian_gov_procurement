#### Preamble ####
# Purpose: EDA
# Author: Robert Ford
# Date: 23 November 2024
# Contact: robert.ford@mail.utoronto.ca
# License: MIT
# Pre-requisites: 
# - The `tidyverse` package must be installed and loaded
# Other information? Make sure you are in the `canadian_gov_procurement` rproj


#### Workspace setup ####
library(tidyverse)

#### Read data ####
df <- read_csv("data/analysis_data/cleaned_data.csv")
View(df)

u_dsupps <- df %>%
  filter(buyer == "National Defence", amount >= 100000) %>%
  group_by(supplier) %>%
  summarize(total_amount = sum(amount, na.rm = TRUE), .groups = "drop")

# Display the unique suppliers
View(u_dsupps)

one_dollar <- df %>%
  filter(amount == 1) %>%
  summarize(number_of_one_dollar_contracts = n())

print(one_dollar)

u_contracts <- data.frame(unique(df$contract))

max.print(u_contracts)

u_buyers <- data.frame(unique(df$buyer))

u_supps <- data.frame(unique(df$supplier))

View(u_buyers)

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

dept_total <- df %>%
  filter(buyer == "Canadian Space Agency") %>%
  summarize(total_amount = sum(amount, na.rm = TRUE)) %>%
  pull(total_amount)

supp_total <- df %>%
  filter(processed_supplier == "dettwiler") %>%
  summarize(total_amount = sum(amount, na.rm = TRUE)) %>%
  pull(total_amount)

total_spend <- df %>%
  summarize(total_amount = sum(amount, na.rm = TRUE)) %>%
  pull(total_amount)

print(supp_total / dept_total)

print(dept_total)

print(dept_total/ total_spend)


war_planes <- 1792979385 + 11219370646 + 3718137594 + 4482200974 + 4322729867

print(war_planes)

View(contracts_expiring)
View(public_health)
View(defence)
