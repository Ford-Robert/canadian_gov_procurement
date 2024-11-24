#### Preamble ####
# Purpose: EDA, Augementing data by calculating per annum spending
# Author: Robert Ford
# Date: 23 November 2024
# Contact: robert.ford@mail.utoronto.ca
# License: MIT


#### Workspace setup ####
library(tidyverse)
library(rstanarm)

#### Read data ####
cleaned <- read_csv("data/analysis_data/cleaned_data.csv")

u_supps <- data.frame(unique(cleaned$supplier))

u_buyers <- data.frame(unique(cleaned$buyer))

View(u_buyers)


View(cleaned)

