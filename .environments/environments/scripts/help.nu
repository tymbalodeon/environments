#!/usr/bin/env nu

use ../../generic/scripts/environment.nu get-project-path
use ../../generic/scripts/help.nu display-just-help

# View help text
def main [
  recipe?: string # View help text for recipe
  ...subcommands: string  # View help for a recipe subcommand
  --color = "always" # When to use colored output
] {
  let environment = "environments"

  (
    display-just-help
      $recipe
      $subcommands
      --color $color
      --environment $environment
      --justfile .environments/environments/Justfile
  )
}
