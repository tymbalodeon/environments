#!/usr/bin/env nu

use ../.scripts/environments-file.nu get-root

def "main remove" [] {
  (
    rm
      --force
      --recursive
      .pytest_cache
      .python-version
      .ruff_cache
      .venv
      pyproject.toml
      uv.lock
  )
}

def main [] {
  let root = (get-root python)

  if ($root | is-not-empty) {
    main remove
    cd $root
  }

  try { uv init --bare err> /dev/null }
  uv add --dev bpython pytest out+err> /dev/null
  taplo format pyproject.toml out+err> /dev/null

  if (uv python pin | complete | get exit_code) != 0 {
    uv python pin 3.13
  }
}
