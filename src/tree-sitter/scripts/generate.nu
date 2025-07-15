#!/usr/bin/env nu

def main [directory_or_path?: string] {
  let files = if ($directory_or_path | path type) == file {
    [$directory_or_path]
  } else {
    let directory = if ($directory_or_path | is-empty) {
      "."
    } else {
      $directory_or_path
    }

    fd grammar --extension js $directory
    | lines
  }

  for file in $files {
    bun run tree-sitter generate --js-runtime bun $file
  }
}
