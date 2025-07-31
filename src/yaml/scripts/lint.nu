#!/usr/bin/env nu

# Lint yaml files
def main [
  ...paths: string # Files or directories to format
] {
  let paths = if ($paths | is-empty) {
    ["."]
  } else {
    $paths
  }

  yamllint ...$paths
}
