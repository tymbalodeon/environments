# TODO: add submodule aliases to main Justfile when they don't conflict
def main [
  --active-environments: string
  --environments-directory: string
  --inactive-environments: string
  --local-justfiles: string
] {
  for environment in ($inactive_environments | split row " ") {
    rm --force $"just/($environment).just"

    let scripts_directory = $"scripts/($environment)"

    if ($scripts_directory | path exists) {
      sudo rm --force --recursive $"scripts/($environment)"
    }
  }

  open $"($environments_directory)/generic/Justfile"
  | append "\n"
  | str join
  | save --force Justfile

  let active_environments = (
    $active_environments
    | split row " "
    | filter {
        |environment|

        $environment != generic and (
          $"($environments_directory)/($environment)/Justfile"
          | path exists
        )
      }
  )

  for environment in (
    $active_environments ++ ($local_justfiles | split row " ")
  ) {
    $"mod ($environment) \"just/($environment).just\"" 
    | save --append Justfile
  }

  for environment in $active_environments {
    let environment_path = $"($environments_directory)/($environment)";
    let justfile = $"($environment_path)/Justfile"

    (
      cp 
        --recursive 
        --update 
        $"($environment_path)/Justfile"
        $"./just/($environment).just"
    )

    let scripts_directory = $"($environment_path)/scripts/($environment)"

    (
      cp
        --recursive
        --update
        $"($environment_path)/scripts/($environment)"
        ./scripts
    )
  }
}
