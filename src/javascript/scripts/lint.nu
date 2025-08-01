#!/usr/bin/env nu

use ../../default/scripts/paths.nu get-paths

# Lint javascript files
def main [
  ...paths: string # Files or directories to format
] {
  biome lint --write ...(get-paths $paths)
}
