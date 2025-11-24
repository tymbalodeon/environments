#!/usr/bin/env nu

use ../../default/scripts/paths.nu get-paths

# Format css files
def main [
  ...paths: string # Files or directories to format
] {
  pretter --parser css --write ...(get-paths $paths)
}
