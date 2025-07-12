#!/usr/bin/env nu

export def get-script [
  recipe: string
  scripts: list<string>
] {
  let parts = (
    $recipe
    | split row "::"
    | split row "/"
  )

  let environment = if ($parts | length) == 1 {
    ""
  } else {
    $parts
    | first
  }

  let $recipe = ($parts | last)

  let matching_scripts = (
    $scripts
    | where {
        let path = ($in | path parse)

        $path.stem == $recipe and $path.extension == "nu"
      }
  )

  let matching_scripts = if ($matching_scripts | length) > 1 {
    if ($environment | is-not-empty) {
      $matching_scripts
      | find --no-highlight $environment
    } else {
      $matching_scripts
    }
  } else {
    $matching_scripts
  }

  try {
    $matching_scripts
    | first
  }
}

export def main [recipe: string] {
  let scripts = (
    fd --exclude tests --extension nu "" .environments
    | lines
  )

  get-script $recipe $scripts
}
