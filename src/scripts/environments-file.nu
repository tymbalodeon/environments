#!/usr/bin/env nu

export def get-root [environment: string] {
  do --ignore-errors {
    open .environments/environments.toml
    | get environments
    | where name == $environment
    | get root
    | first
  }
}
