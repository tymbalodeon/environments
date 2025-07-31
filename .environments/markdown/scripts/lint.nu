#!/usr/bin/env nu

use ../../default/scripts/format.nu get-paths

# Lint markdown files
def main [
  ...paths: string # Files or directories to format
] {
  markdownlint-clit2 ...(get-paths $paths) out> /dev/null
}
