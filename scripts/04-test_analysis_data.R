#### Preamble ####
# Purpose: Tests cleaned_data set
# Author: Robert Ford
# Date: 22 November 2024
# Contact: robert.ford@mail.utoronto.ca
# License: MIT
# Pre-requisites: 
# - The `tidyverse` package must be installed and loaded
# - The `testthat` package must be installed and loaded
# Any other information needed? Make sure you are in the `canadian_gov_procurement` rproj




#### Workspace setup ####
library(tidyverse)
library(testthat)

data <- read_csv("data/analysis_data/cleaned_data.csv")


#### Test data ####

# Test that each column is the right data type
test_that("Columns have the correct data types", {
  expect_type(data$region, "character")
  expect_type(data$contract, "character")
  expect_type(data$buyer, "character")
  expect_type(data$supplier, "character")
  expect_type(data$amount, "double")  # or "integer" if amount is integer
  expect_s3_class(data$award_date, "Date")
  expect_s3_class(data$start_date, "Date")
  expect_s3_class(data$end_date, "Date")
  expect_type(data$link, "character")
  expect_type(data$duration_days, "double")  # or "integer" if it's integer
  expect_type(data$per_day, "double")
})

# Test that 'duration_days' is greater than 0
test_that("duration_days > 0", {
  expect_true(all(data$duration_days > 0))
})

# Test that 'amount' is greater than 0
test_that("amount > 0", {
  expect_true(all(data$amount > 0))
})

# Test that there are no missing values in the dataset
test_that("No missing values in dataset", {
  expect_true(all(!is.na(data)))
})

# Test that there are no duplicate rows
test_that("No duplicate rows", {
  expect_equal(nrow(data), nrow(unique(data)))
})

# Test that 'buyer' and 'supplier' are not empty strings
test_that("'buyer' and 'supplier' are not empty", {
  expect_true(all(nzchar(data$buyer)))
  expect_true(all(nzchar(data$supplier)))
})

# Test that 'per_day' is greater than 0
test_that("per_day > 0", {
  expect_true(all(data$per_day > 0))
})

# Test that date columns are valid dates
test_that("Date columns are valid dates", {
  expect_true(all(!is.na(as.Date(data$award_date))))
  expect_true(all(!is.na(as.Date(data$start_date))))
  expect_true(all(!is.na(as.Date(data$end_date))))
})

# Test that 'start_date' and 'award_date' are not before 2015
test_that("No 'start_date' or 'award_date' before 2015", {
  expect_true(all(analysis_data$start_date >= as.Date("2015-01-01")))
  expect_true(all(analysis_data$award_date >= as.Date("2015-01-01")))
})

# Test that 'end_date' is not beyond 2099
test_that("No 'end_date' beyond 2099", {
  expect_true(all(analysis_data$end_date <= as.Date("2099-12-31")))
})