#!/usr/bin/env nu

use environment.nu get-project-path

def list-nix-files [] {
  let nix_directory = (get-project-path nix)

  mkdir $nix_directory

  ls $nix_directory
  | get name
}

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
  # TODO: either find a way to make this work with the new system, or else
  # remove entirely
  let nix_files = ["flake.nix"] ++ (list-nix-files)

  let nix_files = match $environment {
    null => $nix_files

    _ => (
      $nix_files
      | filter {
          |file|

          let filename = (
            $file
            | path basename
            | path parse
            | get stem
          )

          match $environment {
            "generic" => ($filename == "flake")
            _ => ($filename == $environment)
          }
        }
    )
  }

  let dependencies = (merge-flake-dependencies ...($nix_files | each {open}))

  match $dependency {
    null => (print --no-newline $dependencies)

    _ => (
      try {
        $dependencies
        | rg --color always $dependency
      }
    )
  }
}
