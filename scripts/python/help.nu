#!/usr/bin/env nu

use ../environment.nu get-project-path
use ../help.nu display-aliases
use ../help.nu display-just-help

# View module aliases
def "main aliases" [
  --sort-by-environment # Sort aliases by environment name
  --sort-by-recipe # Sort recipe by original recipe name
] {
  (
    display-aliases
      $sort_by_environment
      $sort_by_recipe
      --justfile just/python.just
  )
}

# View help text
def main [
  recipe?: string # View help text for recipe
  ...subcommands: string  # View help for a recipe subcommand
] {
  let environment = "python"

  (
    display-just-help
      $recipe
      $subcommands
      --environment $environment
      --justfile (get-project-path $"just/($environment).just")
  )
}
