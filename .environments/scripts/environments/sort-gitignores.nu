#!/usr/bin/env nu

def main [] {
  for gitignore in (
    fd --exclude "**/tests/**" --hidden \.gitignore src
    | lines
  ) {
    open $gitignore
    | lines
    | sort
    | save --force $gitignore
  }
}
