#!/usr/bin/env nu

# Initialize a directory
def main [
  ...environments: string # Environments to activate
  --directory: string # Path to the directory to initialize
] {
  if ($directory | is-not-empty) {
    if ($directory | path exists) {
      if ($directory | path type) != dir {
        print --stderr $"(
          ansi red_bold
        )error(ansi reset): ($directory) is not a directory"

        return
      }
    } else {
      mkdir $directory
    }

    cd $directory
  }

  jj git init --colocate
  jj describe --message "chore: initialize environments"
  let temporary_directory = (mktemp --directory --tmpdir)

  (
    git clone
      https://github.com/tymbalodeon/environments.git
      $temporary_directory
  )

  $env.ENVIRONMENTS = $"($temporary_directory)/src"
  cp $"($env.ENVIRONMENTS)/default/flake.nix" flake.nix
  jj new

  if ($environments | is-not-empty) {
    environment add ...$environments
  } else {
    environment activate 
  }

  rm --force --recursive $temporary_directory
}
