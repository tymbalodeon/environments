#!/usr/bin/env nu

use ../../default/scripts/paths.nu get-paths

# Format markdown files
def main [
  ...paths: string # Files or directories to format
] {
  prettier --write ...(get-paths $paths) out> /dev/null
}
