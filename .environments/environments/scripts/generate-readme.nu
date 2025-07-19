#!/usr/bin/env nu

use ../../default/scripts/environment.nu "main list"

def generate-readme-text [section: record<text: string target: string>] {
  let target = $section.target

  open README.md
  | (
      str replace
        --regex (
          $"<!-- ($target) start -->\(.|\\s\)*<!-- ($target) end -->"
        )

        $"<!-- ($target) start -->\n($section.text)\n<!-- ($target) end -->"
    )
  | save --force README.md
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
          target: init

          text: $"```sh
nix run ($remote_url) [ENVIRONMENT]...
```"
        }
      
    )
  } else {
    $sections
  }

  for section in $sections {
    generate-readme-text $section
  }

  prettier --write README.md
}
