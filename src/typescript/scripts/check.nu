#!/usr/bin/env nu

use ../../default/scripts/paths.nu get-paths

# Check javascript files
def main [
  ...paths: string # Files or directories to format
] {
  biome check --write ...(get-paths $paths)
}
