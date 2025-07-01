#!/usr/bin/env nu

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
  try { uv init --bare err> /dev/null }
  uv add --dev bpython pytest
  taplo format pyproject.toml out+err> /dev/null

  if (uv python pin | complete | get exit_code) != 0 {
    uv python pin 3.13
  }
}
