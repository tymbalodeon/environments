#!/usr/bin/env nu

use ../../default/scripts/environment.nu "main list"

def generate-text [
  section: record<files: list<string> target: string text: string>
] {
  let target = $section.target

  for file in $section.files {
    open $file
    | (
        str replace
          --regex (
            $"<!-- ($target) start -->\(.|\\s\)*<!-- ($target) end -->"
          )

          $"<!-- ($target) start -->\n($section.text)\n<!-- ($target) end -->"
      )
    | save --force $file

    if ($file | path parse | get extension) == "md" {
      prettier --write $file
    }
  }
}

# Update repo link in README
def main [] {
  let repo_info = try {
    git remote get-url origin
    | parse "git@{domain}:{user}/{repo}.git"
    | first
  }

  let remote_url = if ($repo_info | is-not-empty) {
    $"($repo_info.domain):($repo_info.user)/($repo_info.repo)?dir=init#"
  }

  let sections = [
    {
      files: [documentation/introduction.md README.md]
      target: environments

      text: (
        main list
        | lines
        | where {$in != generic}
        | each {$'- ($in)'}
        | to text
      )
    }
  ]

  let sections = if ($remote_url | is-not-empty) {
    $sections
    | append (
        {
          files: [documentation/installation.md README.md]
          target: init

          text: $"```sh
nix run \\
  ($remote_url) [ENVIRONMENT]...
```"
        }

    )
  } else {
    $sections
  }

  for section in $sections {
    generate-text $section
  }

  prettier --write README.md
}
