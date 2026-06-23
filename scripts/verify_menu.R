# =======================================================
# DATA VALIDATION PIPELINE (Epi Handbook Architecture)
# =======================================================

# 1. Dynamically manage package dependencies
if (!require("pacman")) install.packages("pacman")
pacman::p_load(tidyverse, janitor)

# 2. Ingest structured database file
db_path <- "database/menu_db.csv"

if (!file.exists(db_path)) {
  stop("❌ CRITICAL ERROR: Ingestion file path '", db_path, "' does not exist.")
}

menu_raw <- readr::read_csv(db_path)
cat("📊 Ingested", nrow(menu_raw), "records for quality review.\n\n")

# 3. Check for Duplicate Identifiers
duplicates <- menu_raw %>% janitor::get_dupes(item_name)
cat("--- DUPLICATE REGISTRY CHECK ---\n")
if (nrow(duplicates) > 0) {
  print(duplicates)
} else {
  cat("✅ Zero duplicate item listings detected.\n")
}

# 4. Check for Missing Critical Core Values (NA or Blanks)
missing_data <- menu_raw %>% 
  dplyr::filter(is.na(item_name) | item_name == "" | is.na(price_usd))

cat("\n--- MISSING VARIABLES CHECK ---\n")
if (nrow(missing_data) > 0) {
  cat("⚠️ Found", nrow(missing_data), "incomplete database entries:\n")
  print(missing_data)
} else {
  cat("✅ Complete data integrity confirmed.\n")
}

# 5. Out-of-Bounds Outlier Validation
invalid_bounds <- menu_raw %>% 
  dplyr::filter(price_usd <= 0.00 | price_usd > 20.00)

cat("\n--- FIELD INTEGRITY THRESHOLD CHECK ---\n")
if (nrow(invalid_bounds) > 0) {
  cat("🛑 CRITICAL: Improbable boundary values flagged:\n")
  print(invalid_bounds)
} else {
  cat("✅ All parameters sit within verified operational limits ($0.01 - $20.00).\n")
}
