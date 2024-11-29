#### Preamble ####
# Purpose: A webscraper to grab IJF procurement awards data, and collate into one combined dataset
# Author: Robert Ford
# Date: 21 November 2024
# Contact: robert.ford@mail.utoronto.ca
# License: MIT
# Pre-requisites: 
# - The application Docker, and Firefox Web driver must be installed
# - The `RSelenium` package must be installed and loaded
# - The `rvest` package must be installed and loaded
# - The `dplyr` package must be installed and loaded
# - The `readr` package must be installed and loaded

# See appendix of paper for detailed step by step instructions
# Be sure to fill in all instances of USER_PATH with where ever you have stored this rproj on your machine

# -! IMPORTANT !- You must FIRST run this code in your terminal which is cd in this file:
# docker run -d -p 4444:4444 -p 5900:5900 -v /USER_PATH/canadian_gov_procurement/data/raw_data:/home/seluser/Downloads selenium/standalone-firefox:3.141.59


# Data was last collected on: 24 November 2024
#### Workspace setup ####
library(RSelenium)
library(rvest)
library(dplyr)
library(readr)

# Paths
# Path inside the container
download_dir <- "/home/seluser/Downloads"

# Path on the host
host_download_dir <- "/USER_PATH/canadian_gov_procurement/data/raw_data"

# Set up Firefox profile with download preferences
fprof <- makeFirefoxProfile(list(
  "browser.download.folderList" = 2,
  "browser.download.dir" = download_dir,
  "browser.helperApps.neverAsk.saveToDisk" = "text/csv,application/csv,text/plain,application/octet-stream",
  "browser.download.manager.showWhenStarting" = FALSE,
  "browser.download.useDownloadDir" = TRUE,
  "browser.helperApps.alwaysAsk.force" = FALSE,
  "pdfjs.disabled" = TRUE  # Disable built-in PDF viewer if downloading PDFs
))

# Initialize remote driver
remDr <- remoteDriver(
  remoteServerAddr = "localhost",
  port = 4444,
  browserName = "firefox",
  extraCapabilities = fprof
)
remDr$open()

# Navigate to the website
url <- "https://theijf.org/procurement/records?table=awards&region=Federal&status=AWARDED&dir=asc&sort=min_date"
remDr$navigate(url)
# Wait for the page to load
Sys.sleep(5)

# Total number of pages to scrape
total_pages <- 329

for (page in 1:total_pages) {
  print(page)
  Sys.sleep(3)
  # Click the "Download" button
  tryCatch({
    download_button <- remDr$findElement(using = "xpath", "//button[@aria-label='Download data']")
    download_button$clickElement()
    Sys.sleep(5)  # Wait for the download to complete
  }, error = function(e) {
    message("Error on page ", page, ": ", e$message)
    next  # Skip to the next iteration
  })
  
  # Click the "Next" button to go to the next page
  if (page < total_pages) {
    tryCatch({
      next_button <- remDr$findElement(using = "xpath", "//button[@aria-label='Next']")
      next_button$clickElement()
      Sys.sleep(3)  # Wait for the next page to load
    }, error = function(e) {
      message("Error clicking 'Next' on page ", page, ": ", e$message)
      break  # Exit the loop if we can't navigate further
    })
  }
}

host_download_dir <- "data/raw_data"

# List all CSV files in the directory
csv_files <- list.files(
  path = host_download_dir,
  pattern = "\\.csv$",  
  full.names = TRUE
)

# Read and combine all CSV files
list_of_data_frames <- lapply(csv_files, read_csv)

# Combine all data frames into one
all_data <- bind_rows(list_of_data_frames)

View(all_data)

# Save the combined data to a single CSV file
combined_csv_path <- file.path(host_download_dir, "combined_data.csv")
write_csv(all_data, combined_csv_path)
