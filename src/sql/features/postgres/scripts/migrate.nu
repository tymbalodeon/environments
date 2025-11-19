#!/usr/bin/env nu

use database.nu get-dev-url
use database.nu get-url

# Migrate the database
def main [
  migrations_directory="database/migrations"
  schema_file="database/schema/schema.sql"
] {
  (
    atlas migrate diff
      --dev-url (get-dev-url)
      --dir $"file://($migrations_directory)"
      --format "{{{{ sql . \"  \" }}"
      --to $"file://($schema_file)"
  )

  atlas migrate apply --dir $"file://($migrations_directory)" --url (get-url)
}
