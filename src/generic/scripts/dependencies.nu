#!/usr/bin/env nu

use environment.nu list-nix-files

def get-flake-dependencies []: string -> list<string> {
  $in
  | rg --multiline 'packages = .+(\n|\[|[^;])+\]'
  | lines
  | drop nth 0
  | filter {|line| "[" not-in $line and "]" not-in $line}
  | str trim
}

export def merge-flake-dependencies [...flakes: string] {
  $flakes
  | each {get-flake-dependencies}
  | flatten
  | uniq
  | sort
  | to text
}

# List dependencies
def main [
  dependency?: string # Search for a dependency
  --environment: string # List only dependencies for $environment
] {
  let nix_files = "flake.nix" ++ (list-nix-files)

  let nix_files = if ($environment | is-empty) {
    $nix_files
  } else {
    $nix_files
    | filter {
        |file|

        let filename = (
          $file
          | path basename
          | path parse
          | get stem
        )

        if $environment == "generic" {
          $filename == "flake"
        } else {
          $filename == $environment
        }
      }
  }

  let dependencies = (merge-flake-dependencies ...($nix_files | each {open}))

  if ($dependency | is-empty) {
    print --no-newline $dependencies
  } else {
    try {
      $dependencies
      | rg --color always $dependency
    }
  }
}
