#!/usr/bin/env nu

# Update pre-commit hooks
def main [
  --verbose # Show errors
] {
  for environment in (ls src | where type == dir | get name) {
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
