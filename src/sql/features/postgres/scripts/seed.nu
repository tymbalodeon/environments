#!/usr/bin/env nu

use database.nu create-database
use database.nu get-database-name

# Seed the database
def main [seed_file="database/queries/seed.sql"] {
  create-database

  # TODO: add warning if it doesn't exist?
  if ($seed_file | path exists) {
    psql (get-database-name) --file $seed_file
  }
}
