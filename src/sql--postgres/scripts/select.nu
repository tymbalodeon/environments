#!/usr/bin/env nu

use postgres.nu start-postgres

# Select items from the database
def main [table: string --limit=10] {
  start-postgres
  psql mishpocha --command $"SELECT * FROM ($table) LIMIT ($limit);"
}
