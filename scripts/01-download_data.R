#### Preamble ####
# Purpose: Downloads and saves the data from [...UPDATE THIS...]
# Author: Rohan Alexander [...UPDATE THIS...]
# Date: 11 February 2023 [...UPDATE THIS...]
# Contact: rohan.alexander@utoronto.ca [...UPDATE THIS...]
# License: MIT
# Pre-requisites: [...UPDATE THIS...]
# Any other information needed? [...UPDATE THIS...]

#### Workspace setup ####
library(RSelenium)
library(rvest)
library(dplyr)
library(readr)
library(readr)
library(dplyr)
#docker run -d -p 4444:4444 -p 5900:5900 -v /Users/robert_ford/canadian_gov_procurement/data/raw_data:/home/seluser/Downloads selenium/standalone-firefox:3.141.59

# Paths
# Path inside the container
download_dir <- "/home/seluser/Downloads"

# Path on the host
host_download_dir <- "/Users/robert_ford/canadian_gov_procurement/data/raw_data"

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
url <- "https://theijf.org/procurement/records?table=awards&region=Federal&status=AWARDED"
remDr$navigate(url)
# Wait for the page to load
Sys.sleep(5)

# Total number of pages to scrape
total_pages <- 330

for (page in 143:total_pages) {
  print(page)
  Sys.sleep(2)
  # Click the "Download" button
  tryCatch({
    download_button <- remDr$findElement(using = "xpath", "//button[@aria-label='Download data']")
    download_button$clickElement()
    Sys.sleep(3)  # Wait for the download to complete
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


# Save the combined data to a single CSV file
combined_csv_path <- file.path(host_download_dir, "combined_data.csv")
write_csv(all_data, combined_csv_path)
