#!/usr/bin/env nu

# Initialize a directory
def main [
  ...environments: string # Environments to activate
  --directory: string # Path to the directory to initialize
  --revision="trunk" # Use another revision besides "trunk"
] {
  if ($directory | is-not-empty) {
    if ($directory | path exists) {
      if ($directory | path type) != dir {
        # TODO: use a shared library for this error printing function
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

  try { jj git init --colocate out+err> /dev/null }
  let temporary_directory = (mktemp --directory --tmpdir)

  (
    git clone
      https://github.com/tymbalodeon/environments.git
      $temporary_directory
      out+err> /dev/null
  )

  $env.ENVIRONMENTS = $"($temporary_directory)/src"
  let environment_script = $"($env.ENVIRONMENTS)/default/scripts/environment.nu"

  print (nu $environment_script revision set --help)

  (
    nu $environment_script revision set
      $revision
      --source-flake $"($env.ENVIRONMENTS)/default/flake.nix"
  )

  jj describe --message "chore: initialize environments" out+err> /dev/null
  jj new out+err> /dev/null

  if ($environments | is-not-empty) {
    nu $environment_script add --skip-activation ...$environments
    jj squash
  }

  nu $environment_script activate
  jj squash
  rm --force --recursive $temporary_directory
}
