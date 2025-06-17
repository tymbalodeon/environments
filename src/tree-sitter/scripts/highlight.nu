#!/usr/bin/env nu

use file.nu open-temporary-file

def get-random-file [files: list<string>] {
  let max_index = (($files | length) - 1)

  $files
  | get (random int 0..$max_index)
}

def main [file: string] {
  let temporary_file = (file $file)
  bun run tree-sitter highlight $temporary_file --config-path config.json
  rm $temporary_file
}
