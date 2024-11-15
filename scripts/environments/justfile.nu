#!/usr/bin/env nu

use ../environment.nu get-project-path

# Run an environment Justfile
def main --wrapped [
  environment?: string # The environment whose Justfile to run
  ...args: string # Arguments to pass to the Justfile
] {
  if $environment == "--self-help" {
    return (help main)
  }

  let environment = match $environment {
    null => "generic"
    _ => $environment
  }

  let base_directory = (get-project-path ("src" | path join $environment))

  let justfile = match $environment {
    "generic" => ($base_directory | path join Justfile)

    _ => {
      let environment_justfile = ("just" | path join $"($environment).just")

      $base_directory
      | path join $environment_justfile
    }
  }

  match $args {
    null => (just --justfile $justfile --list --list-submodules)
    _ => (just --justfile $justfile ...$args)
  }
}
