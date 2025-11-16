#!/usr/bin/env nu

use database.nu get-dev-url
use database.nu get-url

# Migrate the database
def main [] {
  (
    atlas migrate diff
      --dev-url (get-dev-url)
      --dir file://database/migrations
      --format "{{{{ sql . \"  \" }}"
      --to file://database/schema/schema.sql
  )

  atlas migrate apply --dir file://database/migrations --url (get-url)
  psql mishpocha --file database/queries/albums.sql
  psql mishpocha --file database/queries/tracks.sql
}
