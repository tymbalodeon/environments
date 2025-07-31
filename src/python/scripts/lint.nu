#!/usr/bin/env nu

use ../../default/scripts/paths.nu get-paths

# Lint python files
def main [
  ...paths: string # Files or directories to format
] {
  # TODO: add option for --fix
  ruff check ...(get-paths $paths)
}
