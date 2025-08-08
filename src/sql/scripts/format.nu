#!/usr/bin/env nu

use ../../default/scripts/paths.nu get-paths

# Format sql files
def main [
  ...paths: string # Files or directories to format
] {
  # TODO: use sqlfluff by default?
  pg_format ...(get-paths $paths)
}
