#!/usr/bin/env nu

def "main remove" [] {
  rm --force Gemfile
}

def main [] {
  # TODO: make this a shared function
  let root = do --ignore-errors {
    open .environments/environments.toml
    | get environments
    | where name == ruby
    | get root
    | first
  }

  if ($root | is-not-empty) {
    cd $root
  }

  try { bundle init err> /dev/null }
}
