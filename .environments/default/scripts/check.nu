#!/usr/bin/env nu

use ../../git/scripts/leaks.nu

export def run-check [type: string paths: list<string>] {
  let justfiles = (
    open Justfile
    | lines
    | where {str starts-with mod}
    | each {
        let environment = (
          split row "mod "
          | last
          | split row " "
          | first
        )

        $".environments/($environment)/Justfile"
      }
    | where {path exists}
    | each {
        |environment|

        let recipes = (
          just --summary --justfile $environment
          | split row " "
        )

        if type in $recipes {
          $environment
        }
      }
    | where {is-not-empty}
  )

  for justfile in $justfiles {
    let environment = ($justfile | path split | get 1)
    print $"($type | str capitalize)ing ($environment) files..."
    just --justfile $justfile $type ...$paths
  }
}

def get-default-checks [] {
  ls .environments/default/scripts/check-*
  | get name
  | each {
      {
        file: $in
        name: ($in | path parse | get stem | str replace check- "")
      }
    }
}

# List checks
def "main list" [] {
  get-default-checks
  | get name
  | append [
      flake
      leaks
    ]
  | sort
  | to text --no-newline
}

# Run checks
export def main [...checks: string] {
  let checks = ($checks | str downcase)
  let all = ($checks | is-empty)

  if $all or ("leaks" in $checks) {
    leaks
  }

  if $all or ("flake" in $checks) {
    # TODO: move this to the nix module?
    nix flake check
  }

  for check in (
    just --summary
    | split row " "
    | where {
        ($in | str ends-with :check) or (
          $in
          | str starts-with format
        ) or (
          $in
          | str starts-with lint
        )
      }
  ) {
    if $all or $check in $checks {
      just $check
    }
  }

  let default_checks = (get-default-checks)

  let checks = if $all {
    $default_checks.name
  } else {
    $checks
  }

  for check_name in $checks {
    if $check_name in $default_checks.name {
      for check in ($default_checks | where name == $check_name) {
        nu $check.file
      }
    }
  }
}
