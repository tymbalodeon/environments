#!/usr/bin/env nu

# View help text
def main [
  recipe?: string # View help text for recipe
] {
  if ($recipe | is-empty) {
    (
      just
        --color always
        --justfile environments.just
        --list
    )
  } else {
    nu $"../scripts/environments/($recipe).nu" --help
 }
}
