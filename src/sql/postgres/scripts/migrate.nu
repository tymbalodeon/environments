#!/usr/bin/env nu

use database.nu create-database
use database.nu get-dev-url
use database.nu get-url
use docker.nu start-docker

# Migrate the database
export def main [
  migrations_directory="database/migrations"
  schema_file="database/schema/schema.sql"
] {
  create-database
  start-docker

  (
    atlas migrate diff
      --dev-url (get-dev-url)
      --dir $"file://($migrations_directory)"
      --format "{{{{ sql . \"  \" }}"
      --to $"file://($schema_file)"
  )

  atlas migrate apply --dir $"file://($migrations_directory)" --url (get-url)
}
