#!/usr/bin/env nu

use ../../default/scripts/paths.nu get-paths

# Lint c files
def main [
  ...paths: string # Files or directories to format
] {
  clang-tidy ...(get-paths $paths)
}
