#!/usr/bin/env nu

def main [
  ...paths: string # Files or directories to format
] {
  let paths = if ($paths | is-empty) {
    ["."]
  } else {
    $paths
  }

  # TODO: add option for --fix
  ruff check ...$paths
}
