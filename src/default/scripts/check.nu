#!/usr/bin/env nu

use ../../git/scripts/leaks.nu

def get-submodules [] {
  open Justfile
  | lines
  | where {str starts-with mod}
  | each {
      split row "mod "
      | last
      | split row " "
      | first
    }
}

export def run-check [type: string paths: list<string>] {
  let justfiles = (
    get-submodules
    | each {$".environments/($in)/Justfile"}
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

# TODO: add highlight comment function
# TODO: add --color option

# List checks
def "main list" [] {
  # TODO: add list default
  get-default-checks
  | each {
      $"($in.name) • (ansi blue)# (
        nu $in.file --help
        | split row "\n\n"
        | first
      )(ansi reset)"
    }
  | append [
      default
      leaks
    ]
  | sort
  | to text
  | column -t -s •
}

# Run checks
export def main [...checks: string] {
  let checks = ($checks | str downcase)
  let all = ($checks | is-empty)

  if $all or ("leaks" in $checks) {
    leaks
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

  let checks = if $all or ("default" in $checks) {
    $default_checks.name
  } else {
    $checks
  }

  let submodules = (get-submodules)

  for check_name in $checks {
    if $check_name in $default_checks.name {
      for check in ($default_checks | where name == $check_name) {
        nu $check.file
      }
    } else if $check_name in $submodules {
      just $check_name check
    }
  }
}
