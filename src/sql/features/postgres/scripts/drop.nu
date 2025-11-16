#!/usr/bin/env nu

use database.nu get-database-name
use database.nu get-database-names
use postgres.nu start-postgres

# Drop database
def main [] {
  start-postgres

  if (get-database-name) in (get-database-names) {
    dropdb (get-database-name)
  }
}
