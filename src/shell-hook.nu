def main [
  --active-environments: string
  --environments-directory: string
  --inactive-environments: string
  --local-justfiles: string
] {
  for environment in $inactive_environments {
    let justfile = $"./just/($environment).just"

    if ($justfile | path exists) {
      rm --force $justfile
    }

    let scripts_directory = $"./scripts/($environment)"

    if ($scripts_directory | path exists) {
      sudo rm --force --recursive $scripts_directory
    }
  }

  open $"($environments_directory)/generic/Justfile"
  | append "\n"
  | str join
  | save --force Justfile

  for environment in (
    (
      ($active_environments | split row " ")
      | filter {
          |file|

          $file != generic and (
            $"($environments_directory)/($file)/Justfille"
            | path exists
          )
        }
    ) ++ ($local_justfiles | split row " ")
  ) {
    $"mod ($environment) \"just/($environment).just\"" 
    | save --append Justfile
  }
}
