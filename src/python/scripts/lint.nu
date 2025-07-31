#!/usr/bin/env nu

# TODO: move this out of format, since lint also uses it -- make it its own
# file?
use ../../default/scripts/format.nu get-paths

# Lint python files
def main [
  ...paths: string # Files or directories to format
] {
  # TODO: add option for --fix
  ruff check ...(get-paths $paths)
}
