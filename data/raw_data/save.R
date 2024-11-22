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

for (page in 1:total_pages) {
  
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

