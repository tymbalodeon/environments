#!/usr/bin/env nu

# Format files
def main [
  ...paths: string # Files or directories to format
] {
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

        if "format" in $recipes {
          $environment
        }
      }
    | where {is-not-empty}
  )

  for justfile in $justfiles {
    print $"Formatting ($justfile | path split | get 1) files..."
    just --justfile $justfile format ...$paths
  }
}
