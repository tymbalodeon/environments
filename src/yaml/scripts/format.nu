#!/usr/bin/env nu

use ../../default/scripts/format.nu get-paths

def main [
  ...paths: string # Files or directories to format
] {
  yamlfmt ...(get-paths $paths)
}
