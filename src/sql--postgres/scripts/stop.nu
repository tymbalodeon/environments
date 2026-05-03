#!/usr/bin/env nu

use docker.nu stop-docker
use postgres.nu stop-postgres

# Stop docker daemon and postgresql server
def main [] {
  stop-docker
  stop-postgres
}
