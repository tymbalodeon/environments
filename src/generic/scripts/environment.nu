#!/usr/bin/env nu

def get-project-root [] {
  echo (git rev-parse --show-toplevel)
}

export def get-project-path [path: string] {
  (get-project-root)
  | path join $path
}

# Activate installed environments
def "main activate" [] {
  if (which direnv | is-empty) {
    print "Direnv (https://direnv.net/) is not installed."
    print "Please install and try again."

    exit 1
  }

  "use flake"
  | save --force .envrc

  direnv allow
}

# Add environments to the project
export def "main add" [...environments: string] {
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

# List environment files
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

# Remove environments from the project
def "main remove" [
  ...environments: string
  --reactivate
] {
  open .environments.toml
  | update environments (
      (open .environments.toml).environments
      | where {$in not-in $environments}
    )
  | save --force .environments.toml

  main activate
}

# Run tests
def "main test" [
  --match-suites: string # Regular expression to match against suite names (defaults to all)
  --match-tests: string # Regular expression to match against test names (defaults to all)
] {
  let command = "use nutest; nutest run-tests"

  let command = if ($match_suites | is-not-empty) {
    $"($command) --match-suites ($match_suites)"
  } else {
    $command
  }

  let command = if ($match_tests | is-not-empty) {
    $"($command) --match-tests ($match_tests)"
  } else {
    $command
  }

  (
    nu
      --commands $command
      --include-path $env.NUTEST
  )
}

# Update environment dependencies
def "main update" [] {
  nix flake update
}

# View the contents of a remote environment file
def "main source" [
  environment: string
  file: string
] {
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

def main [
  environment?: string
] {
  if ($environment | is-empty) {
    return (help main)
  }

  get-installed-environments
  | sort
  | str join
}
