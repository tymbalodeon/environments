#!/usr/bin/env nu

use ../generic/scripts/domain.nu

def "main remove" [] {
  rm --force book.toml
  rm --force --recursive book documentation
}

def main [] {
  if ("documentation" | path exists) {
    if ("documentation" | path type) == dir {
      return
    } else {
      rm documentation
    }
  }

  let title = do --ignore-errors {
    open .environments.toml
    | get environments
    | where name == documentation
    | get title
    | first
  }

  let title = if ($title | is-empty) {
    match (domain) {
      "github" => (gh repo view --json name | from json | get name)
      "gitlab" => (glab repo view --output json | from json | get path)
      _ => (pwd | path basename)
    }
  }

  mkdir documentation
  mdbook init --ignore none --title $title

  open book.toml
  | update book.src documentation
  | save --force book.toml

  mv src/SUMMARY.md documentation
  mv src/chapter_1.md documentation
}
