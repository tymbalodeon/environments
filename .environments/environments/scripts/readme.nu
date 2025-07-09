#!/usr/bin/env nu

use ../../generic/scripts/environment.nu get-project-path
use ../../generic/scripts/environment.nu "main list"

def generate-readme-text [text: string target: string] {
  let readme = (get-project-path README.md)

  let text = $"<!-- ($target) start -->\n($text)\n<!-- ($target) end -->"

  open $readme
  | (
      str replace
        --regex (
          $"<!-- ($target) start -->\(.|\\s\)*<!-- ($target) end -->"
        )

        $text
    )
  | save --force $readme
}

# Update repo link in README
def main [] {
  let sections = [
    {
      target: environments

      text: (
        main list
        | lines
        | where {$in != generic}
        | each {$'- ($in)'}
        | to text
      )
    }

    {
      target: init

      # TODO: generate the url dynamically using git
      text: "```sh
nix run github:tymbalodeon/environments?dir=init# --no-write-lock-file \\
  init [ENVIRONMENT]...
```"
    }
  ]

  for section in $sections {
    generate-readme-text $section.text $section.target
  }

  prettier --write README.md
}
