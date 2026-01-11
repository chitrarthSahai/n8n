# Generate random suffix for globally unique resource names
resource "random_string" "unique_suffix" {
  length  = 4
  special = false
  upper   = false
}

# Storage account removed - using Postgres for persistence instead of SQLite on Azure Files
