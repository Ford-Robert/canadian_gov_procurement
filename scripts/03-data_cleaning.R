#### Preamble ####
# Purpose: Cleans combined raw data set
# Author: Robert Ford
# Date: 22 November 2024
# Contact: robert.ford@mail.utoronto.ca
# License: MIT
# Pre-requisites: 
# - The `tidyverse` package must be installed and loaded
# - The `dplyr` package must be installed and loaded
# - The `stringr` package must be installed and loaded
# Other information? Make sure you are in the `canadian_gov_procurement` rproj


#### Workspace setup ####
library(tidyverse)
library(dplyr)
library(stringr)

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

df <- cleaned

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

# 2. Define Word Pairs to Concatenate
# Each element is a vector of words to concatenate
word_pairs_to_concatenate <- list(
  c("vancouver", "shipyards")
  # Add more pairs here if needed, e.g., c("another", "pair")
)

# Function to concatenate specific word pairs
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

# 3. Process Supplier Names
df <- df %>%
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

# 4. Initialize an Empty Named Vector for the Dictionary
word_dict <- c()

# 5. Loop Through Each Supplier and Accumulate Amounts
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

# 6. Convert the Dictionary to a Dataframe
word_df <- data.frame(
  word = names(word_dict),
  total_amount = as.numeric(word_dict),
  stringsAsFactors = FALSE
)

# 7. Identify the Top Ten Words by Total Amount
top_ten <- word_df %>%
  arrange(desc(total_amount)) %>%
  slice_head(n = 10)

# 8. Associate Each Top Word with a Supplier Name
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

# 9. Prepare Data for Stacked Bar Chart
# For each top ten word, find all occurrences and sum amounts by buyer

# Create a long dataframe with one row per word per buyer
long_df <- df %>%
  mutate(word = processed_supplier) %>%
  unnest(word) %>%
  filter(word %in% top_ten$word)

# Now, aggregate amounts by word and buyer
aggregated_df <- long_df %>%
  group_by(word, buyer) %>%
  summarize(total_amount = sum(amount), .groups = 'drop')

# To ensure all top ten words are present even if some buyers didn't contribute
aggregated_df <- aggregated_df %>%
  right_join(
    expand.grid(word = top_ten$word, buyer = unique(df$buyer)),
    by = c("word", "buyer")
  ) %>%
  mutate(total_amount = ifelse(is.na(total_amount), 0, total_amount))

write.csv(aggregated_df, "data/analysis_data/top_ten_suppliers.csv", row.names = FALSE)

# 10. Create a Stacked Bar Chart for the Top Ten Suppliers
# Merge with top_ten to get supplier names if needed
aggregated_df <- aggregated_df %>%
  left_join(top_ten %>% select(word, supplier_name), by = "word")

# Create the bar chart with legend removed
ggplot(aggregated_df, aes(x = reorder(word, total_amount), y = total_amount, fill = buyer)) +
  geom_bar(stat = "identity") +
  coord_flip() +
  labs(
    title = "Top 10 Suppliers by Aggregated Amount Awarded",
    x = "Supplier",
    y = "Total Amount Awarded"
    # Remove the legend title by not specifying 'fill' in labs
  ) +
  theme_minimal() +
  theme(legend.position = "none")

# 10. Transform `processed_supplier` into a Character Column for CSV
df <- df %>%
  mutate(
    processed_supplier = sapply(processed_supplier, function(x) {
      if(length(x) > 0) {
        paste(x, collapse = " ")
      } else {
        ""  # Represent empty lists as empty strings
      }
    })
  )

cleaned <- df

#View(cleaned)

#### Save data ####
write_csv(cleaned, "data/analysis_data/cleaned_data.csv")
