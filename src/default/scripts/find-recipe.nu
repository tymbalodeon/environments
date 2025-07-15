#!/usr/bin/env nu

export def choose-recipe [environment?: string] {
  let recipes = (just --summary | split row " ")

  let recipes = if ($environment | is-not-empty) {
    $recipes
    | where {$"($environment)::" in $in}
  } else {
    $recipes
  }

  $recipes
  | each {
      |recipe|

      if :: in $recipe {
        let parts = ($recipe | split row ::)

       $".environments/($parts | first)/scripts/($parts | last).nu"
      } else {
        $".environments/default/scripts/($recipe).nu"
      }
  }
  | to text
  | (
      fzf
        --preview
        "bat --force-colorization {}"
    )
  | str trim
  | split row " "
  | first
}

# Search available `just` recipes
def main [
  search_term?: string # Regex pattern to match
] {
  # TODO: keep the environment name in the output text, so it's clear which
  # environment a matching recipe belongs to
  let command = if ($search_term | is-empty) {
    choose-recipe
    | path parse
    | get stem
  } else {
    $search_term
  }

  just
  | rg $command
}
