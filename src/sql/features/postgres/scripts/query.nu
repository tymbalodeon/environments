#!/usr/bin/env nu

use database.nu get-database-name
use postgres.nu start-postgres

# Query the database
def main [
  query: string
  --csv
] {
  start-postgres
  
  if $csv {
    psql (get-database-name) --command $"($query)" --csv
  } else {
    psql (get-database-name) --command $"($query)"
  }
}
