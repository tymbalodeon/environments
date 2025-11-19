#!/usr/bin/env nu

use database.nu get-database-name
use setup-postgres.nu

# Seed the database
def main [seed_file="database/queries/seed.sql"] {
  setup-postgres

  # TODO: add warning if it doesn't exist?
  if ($seed_file | path exists) {
    psql (get-database-name) --file $seed_file
  }
}
