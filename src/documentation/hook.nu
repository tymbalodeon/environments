#!/usr/bin/env nu

use ../default/scripts/domain.nu

def "main remove" [] {
  (
    rm
      --force
      --recursive
      book
      book.toml
      documentation
      .github/workflows/mdbook.yml
  )
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
    open .environments/environments.toml
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
  mdbook init documentation --ignore none --title $title

  open .github/workflows/mdbook.yml
  | update jobs.build.env.MDBOOK_VERSION (
      mdbook --version
      | split row " "
      | last
      | parse 'v{version}'
      | first
      | get version
    )
}
