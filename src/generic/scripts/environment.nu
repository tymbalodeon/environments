#!/usr/bin/env nu

use project.nu get-project-path

# Activate installed environments
def "main activate" [] {
  if (which direnv | is-empty) {
    print "Direnv (https://direnv.net/) is not installed."
    print "Please install and try again."

    exit 1
  }

  "use flake"
  | save --force (get-project-path .envrc)

  direnv allow
}

def initialize [] {
  if not (".environments.toml" | path exists) {
    cp $"($env.ENVIRONMENTS)/generic/.environments.toml" .
  }

  cp $"($env.ENVIRONMENTS)/generic/flake.nix" .
  chmod +w flake.nix
}

# Add environments to the project
export def "main add" [...environments: string] {
  initialize

  open .environments.toml
  | update environments (
      (open .environments.toml).environments
      | append $environments
      | uniq
      | sort
    )
  | save --force .environments.toml

  main activate
}

# List environments and files
def "main list" [
  environment?: string
  path?: string
] {
  if ($environment | is-empty) {
    ls --short-names $env.ENVIRONMENTS
    | where type == dir
    | get name
    | str join "\n"
  } else if ($path | is-empty) {
    fd --type file "" $"($env.ENVIRONMENTS)/($environment)"
    | lines
    | each {|file| $file | split row $"src/($environment)/" | last}
    | str join "\n"
  } else {
    ls --short-names $"($env.ENVIRONMENTS)/($environment)/($path)"
    | get name
    | str join "\n"
  }
}

# List installed environments
def "main list installed" [
  --all # Show all installed environments
  --default # Show only default installed environments
  --user # Show only user installed environments [default]
] {
  # TODO: show local environments
  let default_environments = (
    open $"($env.ENVIRONMENTS)/generic/.environments.toml"
  ).environments

  let environments = (open .environments.toml).environments

  let environments = if $all {
    $environments
  } else if $default {
    $environments
    | where {$in in $default_environments}
  } else {
    $environments
    | where {$in not-in $default_environments}
  }

  $environments
  | str join "\n"
}

# Remove environments from the project
def "main remove" [
  ...environments: string
  --reactivate
] {
  initialize

  open .environments.toml
  | update environments (
      (open .environments.toml).environments
      | where {$in not-in $environments}
    )
  | save --force .environments.toml

  main activate
}

# View the contents of a remote environment file
def "main source" [
  environment: string
  file: string
] {
  # TODO: make env and file optional and use fzf in those cases
  let files = (^fd $file $"($env.ENVIRONMENTS)/($environment)")

  if ($files | is-empty) {
    return
  }

  let file = if ($files | lines | length) > 1 {
    $files
    | fzf
  } else {
    $files
  }

  bat $file
}

alias "main src" = main source

# Run tests
def "main test" [
  --suites: string # Regular expression to match against suite names (defaults to all)
  --tests: string # Regular expression to match against test names (defaults to all)
] {
  let command = "use nutest; nutest run-tests"

  let command = if ($suites | is-not-empty) {
    $"($command) --match-suites ($suites)"
  } else {
    $command
  }

  let command = if ($tests | is-not-empty) {
    $"($command) --match-suites ($tests)"
  } else {
    $command
  }

  nu --commands $command --include-path $env.NUTEST
}

# Update environment dependencies
def "main update" [] {
  nix flake update
}

def main [] {
  help main
}
