#!/usr/bin/env nu

use docker.nu start-docker
use postgres.nu start-postgres

# Start docker daemon and postgresql server
def main [] {
  start-docker
  start-postgres
}
