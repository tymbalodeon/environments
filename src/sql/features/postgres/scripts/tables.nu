#!/usr/bin/env nu

use postgres.nu start-postgres

# List table names
def main [] {
  start-postgres

  psql mishpocha --command '\dt' --csv
  | from csv
  | get Name
  | to text
}
