#!/usr/bin/env nu

def main [file: string] {
  # TODO DRY me up (see highlight)
  let files = (
    ls test/corpus/**/*
    | where type == file
    | get name
  )

  let file = if ($file | path exists) {
    $file
  } else if ($file | is-not-empty) {
    try {
      let files = (
        $files
        | find --no-highlight $file
      )

      if ($files | length) == 0 {
        return
      } else if ($files | length) == 1 {
        $files
        | first
      } else {
        $files
        | to text
        | fzf --preview 'open {}'
      }
    } catch {
      return
    }
  } else {
    get-random-file $files
  }

  let temporary_file = (mktemp --tmpdir XXX.ck)

  open $file
  | split row "\n---\n"
  | first
  | split row "=\n"
  | last
  | str trim
  | save --force $temporary_file

  bun run tree-sitter parse --no-ranges $temporary_file
  rm $temporary_file
}
