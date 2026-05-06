#!/usr/bin/env nu

use ../../default/scripts/paths.nu get-paths

# Format html files
def main [
  ...paths: string # Files or directories to format
] {
  prettier --parser html --wrtie ...(get-paths $paths)
}
