#!/usr/bin/env nu

use find-script.nu

# View help text
def main [
  recipe?: string # View help text for recipe
] {
  if ($recipe | is-empty) {
    return (
      just
        --color always
        --list
        --list-submodules
    )
  }

  let script = (find-script $recipe)

  print $script

  if ($script | is-empty) {
    try {
      return (just --color always --list $recipe --quiet)
    } catch {
      return
    }
  }

  if "def main --wrapped" in (open $script) {
    nu $script "--self-help"
  } else {
    nu $script --help
  }
}
