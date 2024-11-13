#!/usr/bin/env nu

use ../filesystem.nu get-project-path

# View help text
def main [
  recipe?: string # View help text for recipe
] {
  if ($recipe | is-empty) {
    (
      just
        --color always
        --justfile (get-project-path just/environments.just)
        --list
    )
  } else {

    nu $"../scripts/environments/($recipe).nu" --help
 }
}
