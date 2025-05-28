#!/usr/bin/env nu

use ../help.nu display-just-help
use ../project.nu get-project-path

# View help text
def main [
  recipe?: string # View help text for recipe
  ...subcommands: string  # View help for a recipe subcommand
] {
  let environment = "zola"

  (
    display-just-help
      $recipe
      $subcommands
      --environment $environment
      --justfile (get-project-path $"just/($environment).just")
  )
}
