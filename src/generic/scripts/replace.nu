#!/usr/bin/env nu

use environment.nu get-project-root

def main [
  find: string # The text to match and replace
  replace: string # The text to replace with
  path?: string # Limit to a specific path
] {
  let path = if ($path | is-empty) {
    get-project-root
  } else {
    $path
  }

  for file in (fd --exclude *.lock --type file "" $path | lines) {
    sd $find $replace $file.name
  }
}
