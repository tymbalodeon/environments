#!/usr/bin/env nu

use ../environment.nu get-project-path

# Update pre-commit hooks
def "main pre-commit" [
  --verbose # Show errors
] {
  for environment in (
    ls (get-project-path src)
    | where type == dir
    | get name
  ) {
    cd $environment

    try {
      if $verbose {
        uv run pre-commit-update
      } else {
        uv run pre-commit-update err> /dev/null
      }
    }

    cd -
  }
}

# Update init flake
def "main init" [] {
  cd (get-project-path init)
  nix flake update
}

# Update init flake and pre-commit hooks
def main [
  --verbose # Show errors
] {
  if $verbose {
    main pre-commit --verbose
  } else {
    main pre-commit
  }

  main init
}
