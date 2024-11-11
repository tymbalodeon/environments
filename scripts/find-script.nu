#!/usr/bin/env nu

use filesystem.nu get-project-absolute-path

export def get-script [recipe: string scripts: list<string>] {
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

  let scripts_directory = (get-project-absolute-path scripts)

  let matching_scripts = (
    $scripts
    | filter {
        |script|

        let path = ($script | path parse)
        let parent = ($path | get parent)
        
        if ($environment | is-not-empty) and (
          $parent != ($scripts_directory | path join $environment)
        ) {
          return false
        }

        $path.stem == $recipe and $path.extension == "nu"
      }
  )

  try {
    $matching_scripts
    | first
  }
}

export def main [recipe: string] {
  let scripts = (
    fd --exclude tests --type file "" (get-project-absolute-path scripts)
    | lines
  )

  get-script $recipe $scripts
}
