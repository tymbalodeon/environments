#!/usr/bin/env nu

use ../../default/scripts/check.nu *

# Clean pre-commit cache
def "main clean" [] {
  clean
}

def get-local-hooks [] {
  get-pre-commit-hook-names (
    {
      repos: (
        open .pre-commit-config.yaml
        | get repos
        | where repo == local
        | flatten
        | get hooks
        | where {"just environments" in $in.entry}
        | wrap hooks
      )
    }
  )
}

def filter-to-local-hooks [hooks?: list<string>] {
  let local_hooks = (get-local-hooks)

  if ($hooks | is-empty) {
    $local_hooks
  } else {
    $hooks
    | where {$in in $local_hooks}
  }
}

# List hook ids
def "main list" [] {
  get-local-hooks
  | to text
}

# Update all pre-commit hooks
def "main update" [] {
  update
}

# Check flake and run pre-commit hooks
def main [
  ...hooks: string # The hooks to run
  --update # Update all pre-commit hooks
] {
  let hooks = (filter-to-local-hooks $hooks)

  if ($hooks | is-empty) {
    return
  }

  if $update {
    check --update ...$hooks
  } else {
    check ...$hooks
  }
}
