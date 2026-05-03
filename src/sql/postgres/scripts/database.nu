#!/usr/bin/env nu

use postgres.nu start-postgres

export def get-database-name [] {
  pwd
  | path basename
}

export def get-database-names [] {
  psql --csv --list
  | from csv
  | get Name
}

export def create-database [] {
  start-postgres

  if (get-database-name) not-in (get-database-names) {
    createdb (get-database-name)
  }
}

def get-postgres-version [] {
  if (which postgres | is-not-empty) {
    postgres --version
    | split row " "
    | last
  } else {
    ""
  }
}

export def get-dev-url [] {
  let version = (get-postgres-version )
  let name = (get-database-name)

  $"docker://postgres/($version)/($name)?search_path=public"
}

export def get-url [] {
  $"postgres://(whoami):@localhost:5432/(get-database-name)?sslmode=disable"
}
