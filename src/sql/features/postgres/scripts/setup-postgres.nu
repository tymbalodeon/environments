#!/usr/bin/env nu

export def get-pgdata-directory [] {
  "/var/lib/pgsql/data"
}

def create-path-with-owner [path: string] {
  sudo mkdir --parents $path
  sudo chown (whoami) $path
}

def main [] {
  if not (get-pgdata-directory  | path exists) {
    create-path-with-owner (get-pgdata-directory )
    initdb --pgdata (get-pgdata-directory )
  }

  if (uname).kernel-name == "Linux" {
    let path = "/run/postgresql"

    if not ($path | path exists) {
      create-path-with-owner $path
    }
  }
}
