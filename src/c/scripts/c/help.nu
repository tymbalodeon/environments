#!/usr/bin/env nu

use ../filesystem.nu get-project-path
use ../help.nu display-just-help

# View help text
def main [
  recipe?: string # View help text for recipe
] {
  let environment = "c"

  (
    display-just-help 
      $recipe 
      (get-project-path $"just/($environment).just") 
      $environment
  )
}
