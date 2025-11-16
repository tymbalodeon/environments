#!/usr/bin/env nu

use database.nu create-database
use database.nu get-url

# Inspect the database
def main [] {
  create-database
  atlas schema inspect --url (get-url)
}
