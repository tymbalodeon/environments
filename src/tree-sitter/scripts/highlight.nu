#!/usr/bin/env nu

use file.nu open-temporary-file
use ../../default/scripts/cd-to-root.nu

def main [file?: string] {
  let temporary_file = (open-temporary-file $file)
  cd-to-root tree-sitter
  bun run tree-sitter highlight $temporary_file --config-path config.json
  rm $temporary_file
}
