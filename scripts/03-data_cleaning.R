#### Preamble ####
# Purpose: Cleans combined raw data set
# Author: Robert Ford
# Date: 22 November 2024
# Contact: robert.ford@mail.utoronto.ca
# License: MIT


#### Workspace setup ####
library(tidyverse)

#### Clean data ####
combined <- read_csv("data/raw_data/combined_data.csv")



View(combined)
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

# Fixing typo in on of the entries
cleaned$start_date[cleaned$start_date == "2204-08-01"] <- "2024-08-01"

# Ensure the start_date column is still in Date format after the update
cleaned$start_date <- as.Date(cleaned$start_date, format = "%Y-%m-%d")

#View(cleaned)

# Identify rows where start_day equals end_day
same_day_indices <- which(cleaned$start_date == cleaned$end_date)

# Increment end_day by 1 day where start_day equals end_day
cleaned$end_date[same_day_indices] <- cleaned$end_date[same_day_indices] + 1

# Amortize data over the length of the contract
cleaned$duration_days <- as.numeric(cleaned$end_date - cleaned$start_date)

# Calculate the per_day amount
cleaned$per_day <- ifelse(cleaned$duration_days > 0, cleaned$amount / cleaned$duration_days, NA)

cleaned <- cleaned[cleaned$duration_days > 0, ]

cleaned <- cleaned[cleaned$amount > 0, ]

# Filter out contracts with 'start_date' or 'award_date' before 2015
cleaned <- cleaned[
  cleaned$start_date >= as.Date("2015-01-01") &
    cleaned$award_date >= as.Date("2015-01-01"), ]

# Filter out contracts with 'end_date' beyond 2099
cleaned <- cleaned[cleaned$end_date <= as.Date("2099-12-31"), ]

# Remove rows with any NA values
cleaned <- na.omit(cleaned)


duplicate_rows <- cleaned[duplicated(cleaned) | duplicated(cleaned, fromLast = TRUE), ]

View(duplicate_rows)

# View the dataframe with duplicate rows
head(duplicate_rows)


cleaned <- unique(cleaned)

# Load necessary libraries
library(dplyr)
library(stringr)

# Create a list of words to remove
banned_words <- c(
  "inc", "ltd", "limited", "company", "co", "corporation", "corp", "llc", "the", "and", "of", "canada", "sa",
  "services", "solutions", "technologies", "consulting", "group", "systems", "construction", "canadian",
  "international", "technology", "fuels", "de", "scientific", "university", "associates",
  "ottawa", "air", "northern", "business", "engineering", "global", "oil", "micro", "llp", "communications",
  "research", "motor", "les", "marine", "helicopters", "industries", "interiors", "aviation", "products",
  "consultants", "environmental", "ontario", "fuel", "energy", "management", "equipment", "nisha", "advanced",
  "electric", "service", "lp", "authority", "enterprises", "harbour", "a", "fisher", "resources", "staffing",
  "office", "quebec", "centre", "mechanical", "north", "security", "supplies", "general", "human", "contracting",
  "supply", "world", "industrial", "institute", "incorporated", "maritime", "electronics", "translation",
  "groupe", "professional", "power", "language", "corps", "it", "partnership", "joint", "training",
  "military", "lighting", "program", "defence", "jpo", "ii", "lightning", "space", "macdonald", "land", "systemscanada",
  "in", "aeronautical"
)

word_pairs_to_concatenate <- list(
  c("vancouver", "shipyards")
  # Add more pairs here if needed, e.g., c("another", "pair")
)

concatenate_specific_pairs <- function(words, word_pairs) {
  for(pair in word_pairs) {
    # Check if all words in the pair are present
    if(all(pair %in% words)) {
      # Concatenate the pair into a single string
      concatenated <- paste(pair, collapse = " ")
      # Remove the individual words
      words <- words[!words %in% pair]
      # Add the concatenated word
      words <- c(words, concatenated)
    }
  }
  return(words)
}


cleaned <- cleaned %>%
  mutate(
    # Lowercase all characters and remove punctuation
    processed_supplier = supplier %>%
      tolower() %>%
      str_remove_all("[[:punct:]]") %>%
      str_split("\\s+"),
    
    # Remove banned words
    processed_supplier = lapply(processed_supplier, function(words) {
      setdiff(words, banned_words)
    }),
    
    # Concatenate specific word pairs
    processed_supplier = lapply(processed_supplier, function(words) {
      concatenate_specific_pairs(words, word_pairs_to_concatenate)
    })
  )


word_counts <- cleaned %>%
  unnest(processed_supplier) %>%                 # Expand the lists into rows
  group_by(processed_supplier) %>%               # Group by each word
  summarize(count = n()) %>%                     # Count occurrences
  arrange(desc(count))                           # Sort by descending frequency

# Rename columns for clarity
word_counts <- word_counts %>%
  rename(word = processed_supplier)

#View(word_counts)

#View(cleaned)

df <- cleaned

#View(df)

word_dict <- c()

# 4. Loop Through Each Supplier and Accumulate Amounts
for (i in 1:nrow(df)) {
  words <- df$processed_supplier[[i]]
  amt <- df$amount[i]
  
  for (word in words) {
    if (word %in% names(word_dict)) {
      word_dict[word] <- word_dict[word] + amt
    } else {
      word_dict[word] <- amt
    }
  }
}

# 5. Convert the Dictionary to a Dataframe
word_df <- data.frame(
  word = names(word_dict),
  total_amount = as.numeric(word_dict),
  stringsAsFactors = FALSE
)

# 6. Identify the Top Ten Words by Total Amount
top_ten <- word_df %>%
  arrange(desc(total_amount)) %>%
  slice_head(n = 10)

# 7. Associate Each Top Word with a Supplier Name
# Initialize a vector to store representative supplier names
top_ten$supplier_name <- NA

for (i in 1:nrow(top_ten)) {
  key_word <- top_ten$word[i]
  
  # Find the first supplier that contains the key_word
  supplier_row <- df %>%
    filter(sapply(processed_supplier, function(words) key_word %in% words)) %>%
    slice(1)
  
  if (nrow(supplier_row) > 0) {
    top_ten$supplier_name[i] <- supplier_row$supplier
  } else {
    top_ten$supplier_name[i] <- NA
  }
}

# 8. Display the Top Ten Words with Their Total Amounts and Supplier Names
print(top_ten)

# 9. Create a Bar Chart for the Top Ten Suppliers
# For better visualization, arrange in ascending order
top_ten <- top_ten %>%
  arrange(total_amount)

ggplot(top_ten, aes(x = reorder(word, total_amount), y = total_amount)) +
  geom_bar(stat = "identity", fill = "steelblue") +
  coord_flip() +
  labs(
    title = "Top 10 Words by Aggregated Amount Awarded",
    x = "Word",
    y = "Total Amount Awarded"
  ) +
  theme_minimal()

cleaned <- df

#### Save data ####
write_csv(cleaned, "data/analysis_data/cleaned_data.csv")
