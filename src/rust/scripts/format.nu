#!/usr/bin/env nu

use ../../default/scripts/paths.nu get-paths

def main [
  ...paths: string # Files or directories to format
] {
  cargo fmt ...(get-paths $paths)
}
