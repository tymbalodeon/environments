#!/usr/bin/env nu

# Update pre-commit hooks
def "main pre-commit" [
  --verbose # Show errors
] {
  for environment in (
    ls src
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
  cd init
  nix flake update
}

# Update init flake and pre-commit hooks
def main [
  --verbose # Show errors
] {
  just python update

  if $verbose {
    main pre-commit --verbose
  } else {
    main pre-commit
  }

  main init
}
