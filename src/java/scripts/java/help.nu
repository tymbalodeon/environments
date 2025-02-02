#!/usr/bin/env nu

use ../help.nu display-just-help

# View help text
def main [
  recipe?: string # View help text for recipe
  ...subcommands: string  # View help for a recipe subcommand
] {
  let environment = "java"

  (
    display-just-help
      $recipe
      $subcommands
      --environment $environment
      --justfile $"just/($environment).just"
  )
}
