#!/usr/bin/env nu

use find-script.nu
use find-script.nu choose-recipe

def get-script [
  recipe_or_environment?: string # Recipe or environment name
  recipe?: string # Recipe name
] {
  let recipe_name = if ($recipe | is-not-empty) {
    $"($recipe_or_environment)/($recipe)"
  } else if ($recipe_or_environment | is-not-empty) {
    $recipe_or_environment
  } else {
    choose-recipe
  }

  let script = if ($recipe | is-empty) {
    try {
      find-script $recipe_name true
    }
  } else {
    find-script $recipe_name
  }

  if ($script | is-empty) {
    return
  }

  $script
}

# Open the source code for a recipe
def "main open" [
  recipe_or_environment?: string # Recipe or environment name
  recipe?: string # Recipe name
] {
  let script = (get-script $recipe_or_environment $recipe)

  if ($script | is-not-empty) {
    ^$env.EDITOR $script
  }
}

# View the source code for a recipe
def "main view" [
  recipe_or_environment?: string # Recipe or environment name
  recipe?: string # Recipe name
] {
  let script = (get-script $recipe_or_environment $recipe)

  if ($script | is-not-empty) {
    bat $script
  }
}

# Find a recipe
def "main find" [
  search_term: string # Regex pattern to match
] {
  # TODO: allow passing environment and recipe
  # TODO: remove newline for passing a bad recipe

  let text = (just)

  let default_matches = try {
    $text
    | split row --regex "[a-zA-Z]:\n"
    | get 1
    | lines
    | each {str trim}
    | to text --no-newline
    | rg $"^($search_term)"
  }

  mut output = []

  if ($default_matches | is-not-empty) {
    $output = ($output | append $default_matches)
  }

  let submodules = (
    open Justfile
    | lines
    | where {str starts-with "mod "}
    | each {split row "mod " | last | split row " " | first}
    | each {
        |submodule|

        let matches = try {
          $text
          | split row $"($submodule):"
          | last
          | split row "\n\n"
          | first
          | lines
          | where {is-not-empty}
          | each {str trim}
          | to text --no-newline
          | rg $search_term
        }

        {$submodule: $matches}
      }
    | transpose
    | transpose --header-row
  )

  mut index = 0

  for column in ($submodules | columns) {
    let matches = (
      $submodules
      | get $column
      | where {is-not-empty}
    )

    if ($matches | is-not-empty) {
      if $index > 0 {
        $output = ($output | append "")
      }

      $output = (
        $output
        | append (
          $text
          | rg $"($column):"
          | str trim
          )
      )

      $output = (
        $output
        | append (
            $matches
            | each {$"    ($in)"}
            | to text --no-newline 
          )
      )

      $index += 1
    }
  }

  $output
  | to text --no-newline 
}

# Find, view, or open recipes
def main [$search_term: string] {
  main find $search_term
}
