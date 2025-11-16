#!/usr/bin/env nu

use postgres.nu start-postgres
# Query the database
def main [query: string csv=""] {
  start-postgres
  psql mishpocha --command $"($query)" ...[$"($csv)"]
}
