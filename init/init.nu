#!/usr/bin/env nu

# Initialize a directory
def main [
  ...environments: string # Environments to activate
  --branch="trunk" # Use another revision besides "trunk"
  --directory: string # Path to the directory to initialize
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

  if not ("devenv.nix" | path exists) {
    "{}"
    | save devenv.nix
  }

  let environments_input = {
    flake: false
    url: $"github:tymbalodeon/environments/($branch)?dir=src"
  }

  let project_input = {flake: false url: "path:."}

  let imports = (
    [environments]
    | append ($environments | each {$"environments/($in)"})
  )

  if ("devenv.yaml" | path exists) {
    # TODO: shared function with environment-add?

    let devenv_yaml = (open devenv.yaml)

    $devenv_yaml
    | upsert inputs.environments $environments_input
    | upsert inputs.project $project_input
    | upsert imports (
        $devenv_yaml.imports
        | append $imports
        | uniq
        | sort
      )
    | save --force devenv.yaml
  } else {
    {
      imports: $imports

      inputs: {
        environments: $environments_input
        project: $project_input
      }
    }
    | save devenv.yaml
  }

  if (".environments" | path type) == file {
    rm .environments
  }

  try { jj git init --colocate out+err> /dev/null }

  jj describe --message "chore: initialize environments" out+err> /dev/null
  jj new out+err> /dev/null
}
