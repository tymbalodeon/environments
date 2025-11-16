#!/usr/bin/env nu

# Seed the database
def main [seed_file?: string] {
  let seed_file = if ($seed_file | is-empty) {
    "database/queries/seed.sql"    
  } else {
    $seed_file
  }

  # TODO: add warning if it doesn't exist?
  if ($seed_file | path exists) {
    psql mishpocha --file $seed_file
  }
}
