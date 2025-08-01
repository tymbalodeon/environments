#!/usr/bin/env nu

use ../../default/scripts/paths.nu get-paths

# Format javascript files
def main [
  ...paths: string # Files or directories to format
] {
  biome format --write ...(get-paths $paths)
}
