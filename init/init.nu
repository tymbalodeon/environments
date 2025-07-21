#!/usr/bin/env nu

# Initialize a directory
def main [
  ...environments: string # Environments to activate
  --directory: string # Path to the directory to initialize
] {
  if ($directory | is-not-empty) {
    cd $directory
  }

  git init

  let temporary_directory = (mktemp --directory --tmpdir)

  (
    git clone
      https://github.com/tymbalodeon/environments.git
      $temporary_directory
  )

  cp $"($env.ENVIRONMENTS)/default/flake.nix" flake.nix
  $env.ENVIRONMENTS = $"($temporary_directory)/src"
  nu $"($env.ENVIRONMENTS)/default/scripts/environment.nu" add ...$environments
  git add .
  rm --force --recursive $temporary_directory
}
