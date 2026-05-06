#!/usr/bin/env nu

use ../../default/scripts/paths.nu get-paths

# Format c files
def main [
  ...paths: string # Files or directories to format
] {
  clang-format ...(get-paths $paths)
}
