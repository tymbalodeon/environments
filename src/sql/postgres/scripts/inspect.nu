#!/usr/bin/env nu

use database.nu create-database
use database.nu get-url
use docker.nu start-docker

# Inspect the database
def main [] {
  create-database
  start-docker
  atlas schema inspect --url (get-url)
}
