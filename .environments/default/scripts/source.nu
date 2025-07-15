#!/usr/bin/env nu

use find-recipe.nu choose-recipe
use find-script.nu

def get-script [
  recipe_or_environment?: string # Recipe or environment name
  recipe?: string # Recipe name
] {
  let recipe = if ($recipe | is-not-empty) {
    $"($recipe_or_environment)/($recipe)"
  } else if ($recipe_or_environment | is-not-empty) {
    $recipe_or_environment
  } else {
    choose-recipe
  }

  let script = (find-script $recipe)

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
  ^$env.EDITOR (get-script $recipe_or_environment $recipe)
}

# View the source code for a recipe
def "main view" [
  recipe_or_environment?: string # Recipe or environment name
  recipe?: string # Recipe name
] {
  bat (get-script $recipe_or_environment $recipe)
}

# View or open the source code for a recipe
def main [
  recipe_or_environment?: string # Recipe or environment name
  recipe?: string # Recipe name
] {
  main view $recipe_or_environment $recipe
}
