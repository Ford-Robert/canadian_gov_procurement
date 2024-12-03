#### Preamble ####
# Purpose: Simulates Government Contract Data
# Author: Robert Ford
# Date: 25 November 2024
# Contact: robert.ford@mail.utoronto.ca
# License: MIT
# Pre-requisites: 
# - The `tidyverse` package must be installed and loaded
# - The `VGAM` package must be installed and loaded
# - The `dplyr` package must be installed and loaded
# - The `lubridate` package must be installed and loaded
# Any other information? Make sure you are in the `canadian_gov_procurement` rproj


#### Workspace setup ####
library(tidyverse)
library(actuar)     # For Pareto distribution
library(dplyr)     # For data manipulation
library(lubridate)

#### Simulate data ####
# Set seed for reproducibility
set.seed(123)

# 1. Define the buyer list excluding "National Defence"
buyer_list <- c(
  "Statistics Canada",
  "Canadian Institutes of Health Research",
  "The National Battlefields Commission",
  "Department of Justice Canada",
  #"National Defence", # Excluded
  "Public Services and Procurement Canada",
  "Canada Revenue Agency",
  "Canada Border Services Agency",
  "Natural Resources Canada",
  "Agriculture and Agri-Food Canada",
  "Correctional Service of Canada",
  "Treasury Board of Canada Secretariat",
  "Environment and Climate Change Canada",
  "Impact Assessment Agency of Canada",
  "Canadian Nuclear Safety Commission",
  "Canadian Food Inspection Agency",
  "Innovation, Science and Economic Development Canada",
  "National Research Council Canada",
  "Employment and Social Development Canada",
  "Health Canada",
  "Crown-Indigenous Relations and Northern Affairs Canada",
  "Indigenous Services Canada",
  "Parks Canada",
  "Canadian Heritage",
  "Financial Consumer Agency of Canada",
  "Financial Transactions and Reports Analysis Centre of Canada",
  "Privy Council Office",
  "Shared Services Canada",
  "Immigration, Refugees and Citizenship Canada",
  "Royal Canadian Mounted Police",
  "Global Affairs Canada",
  "Transport Canada",
  "Fisheries and Oceans Canada",
  "Natural Sciences and Engineering Research Council of Canada",
  "Canadian Intergovernmental Conference Secretariat",
  "Canadian Radio-television and Telecommunications Commission",
  "Polar Knowledge Canada",
  "Office of the Superintendent of Financial Institutions Canada",
  "Public Health Agency of Canada",
  "Courts Administration Service",
  "Immigration and Refugee Board of Canada",
  "National Film Board",
  "Canadian Space Agency",
  "Canada School of Public Service",
  "Infrastructure Canada",
  "Social Sciences and Humanities Research Council of Canada",
  "Parole Board of Canada",
  "Canada Energy Regulator",
  "Civilian Review and Complaints Commission for the RCMP",
  "Public Prosecution Service of Canada",
  "Department of Finance Canada",
  "Public Safety Canada",
  "Canadian Human Rights Commission",
  "Canadian Transportation Agency",
  "Office of the Auditor General of Canada",
  "Elections Canada",
  "Federal Economic Development Agency for Southern Ontario",
  "Library and Archives Canada",
  "Office of the Commissioner for Federal Judicial Affairs Canada",
  "Public Service Commission of Canada",
  "International Joint Commission",
  "Western Economic Diversification Canada",
  "Transportation Safety Board of Canada",
  "Women and Gender Equality Canada",
  "Canadian Centre for Occupational Health and Safety",
  "Administrative Tribunals Support Service of Canada",
  "Veterans Affairs Canada",
  "Office of the Commissioner of Official Languages",
  "Canada Economic Development for Quebec Regions",
  "Canadian Grain Commission",
  "Military Police Complaints Commission of Canada",
  "Atlantic Canada Opportunities Agency",
  "Canadian Northern Economic Development Agency",
  "Office of the Privacy Commissioner of Canada",
  "Patented Medicine Prices Review Board Canada",
  "Office of the Information Commissioner of Canada",
  "Accessibility Standards Canada",
  "National Security and Intelligence Review Agency",
  "Office of the Secretary to the Governor General",
  "RCMP External Review Committee",
  "Office of the Commissioner of Lobbying of Canada",
  "Invest in Canada",
  "Veterans Review and Appeal Board",
  "Farm Products Council of Canada",
  "The Correctional Investigator Canada",
  "Office of the Public Sector Integrity Commissioner of Canada",
  "Military Grievances External Review Committee",
  "Prairies Economic Development Canada",
  "Office of the Intelligence Commissioner",
  "Pacific Economic Development Canada",
  "Federal Economic Development Agency for Northern Ontario",
  "National Gallery of Canada",
  "Law Commission of Canada"
)

# Total number of buyers excluding "National Defence"
num_buyers <- length(buyer_list)

# 2. Define other lists
# Define a list of contract descriptions
contract_list <- c(
  "Engineering consultants-Other",
  "Other professional services not elsewhere specified",
  "Aircraft parts",
  "Aircraft",
  "Ships and boats Parts",
  "IT Services",
  "Construction Services",
  "Medical Supplies",
  "Office Equipment",
  "Maintenance Services",
  "Transportation Services",
  "Security Services",
  "Environmental Services",
  "Training Services",
  "Research and Development",
  "Legal Services",
  "Financial Services",
  "Marketing Services",
  "Logistics Services",
  "Telecommunications Services"
)

# Define a list of supplier names (example list, can be expanded)
supplier_list <- c(
  "SkyAlyne Canada Limited Partnership",
  "CAE Military Aviation Training Inc.",
  "F-35 Lightning II Joint Program Office (JPO)",
  "Airbus Defence and Space SA",
  "Vancouver Shipyards Co Ltd",
  "Bell Helicopter Textron Canada",
  "Lockheed Martin Canada",
  "Rheinmetall Canada Inc.",
  "General Dynamics Canada",
  "L3Harris Canada",
  "Rheinmetall Defence Canada",
  "Thales Canada Limited",
  "BAE Systems Canada",
  "Rheinmetall Canada Limited",
  "MDA Corporation",
  "Rogers Communications Canada",
  "IBM Canada",
  "SNC-Lavalin",
  "Bombardier Inc.",
  "CGI Group Inc.",
  "Northrop Grumman Canada",
  "Raytheon Canada",
  "Microsoft Canada",
  "Amazon Web Services Canada",
  "Google Canada",
  "IBM Global Services",
  "Deloitte Canada",
  "Accenture Canada",
  "PwC Canada",
  "KPMG Canada",
  "Ernst & Young Canada"
)

n <- 10000

# 80% "National Defence"
num_national_defence <- round(0.8 * n)
num_other_buyers <- n - num_national_defence

# Sample other buyers
other_buyers_sample <- sample(buyer_list, size = num_other_buyers, replace = TRUE)

# Combine buyers
buyer_column <- c(rep("National Defence", num_national_defence), other_buyers_sample)

# Shuffle the buyer column
buyer_column <- sample(buyer_column, size = n, replace = FALSE)

# 4. Simulate the 'contract' column
contract_column <- sample(contract_list, size = n, replace = TRUE)

# 5. Simulate the 'supplier' column
supplier_column <- sample(supplier_list, size = n, replace = TRUE)

# 6. Simulate the 'amount' column using Pareto distribution
# Parameters for Pareto: scale = 10,000; shape = 3.5

scale <- 10000
shape <- 3.5

# Using actuar::rpareto
amount_column <- actuar::rpareto(n, scale = scale, shape = shape)

# 7. Simulate 'award_date' and 'start_date'
# Define date range
start_date_min <- as.Date("2018-01-01")
start_date_max <- as.Date("2024-12-31")

# Generate random award_start_dates
award_start_dates <- as.Date(runif(n, min = as.numeric(start_date_min), max = as.numeric(start_date_max)), origin = "1970-01-01")

# 8. Simulate 'end_date' first, then calculate 'duration_days'

# Define minimum and maximum duration in days
min_duration <- 2000
max_duration <- 12000

# Using log-normal distribution for duration_days
# Adjust meanlog and sdlog to achieve desired range

# Calculate meanlog and sdlog to center around 5000 days
meanlog <- log(5000) - (0.5 * (log(5000) / 2)) # Adjusted for skewness
sdlog <- 0.5

# 8. Simulate 'end_date' first, then calculate 'duration_days'

# Generate duration_days uniformly between 2000 and 12000
duration_days_random <- sample(min_duration:max_duration, size = n, replace = TRUE)

# Generate 'end_date' by adding duration_days_random to 'award_start_dates'
end_dates <- award_start_dates + days(duration_days_random)

# 9. Calculate 'duration_days_column'
duration_days_column <- as.numeric(end_dates - award_start_dates)


# 10. Calculate 'per_day'
per_day_column <- amount_column / duration_days_column

# 11. Set 'region' column as "Federal"
region_column <- rep("Federal", n)

# 12. Assemble the dataframe
simulated_df <- data.frame(
  region = region_column,
  contract = contract_column,
  buyer = buyer_column,
  supplier = supplier_column,
  amount = round(amount_column, 2),
  award_date = award_start_dates,
  start_date = award_start_dates,
  end_date = end_dates,
  duration_days = duration_days_column,
  per_day = round(per_day_column, 3),
  stringsAsFactors = FALSE
)

# Optional: View the first few rows of the simulated dataframe
view(simulated_df)

# Save the simulated data
write.csv(simulated_df, "data/simulated_data/simulated_data.csv", row.names = FALSE)
