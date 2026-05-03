#!/usr/bin/env nu

use setup-postgres.nu get-pgdata-directory
use setup-postgres.nu

export def start-postgres [] {
  setup-postgres

  try {
    pg_ctl --pgdata (get-pgdata-directory) status out+err> /dev/null
  } catch {
    pg_ctl --pgdata (get-pgdata-directory) start
  }
}

export def stop-postgres [] {
  setup-postgres

  if (
    pg_ctl --pgdata (get-pgdata-directory) status
    | complete
    | get exit_code
  ) == 0 {
    pg_ctl --pgdata (get-pgdata-directory) stop
  }
}
