#!/usr/bin/env nu

use database.nu get-database-name
use migrate.nu

# Seed the database
def main [
  # TODO: convert other similar overrides to flags instead of args
  --flush_file="database/queries/flush.sql"
  --seed_file="database/queries/seed.sql"
] {
  # TODO: add confirmation
  migrate

  let database_name = (get-database-name)

  psql $database_name --file $flush_file

  # TODO: add warning if it doesn't exist?
  if ($seed_file | path exists) {
    psql $database_name --file $seed_file
  }
}
