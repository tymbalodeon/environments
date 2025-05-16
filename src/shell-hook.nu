def main [
  --active_environments: list<string>
  --environments_directory: string
  --inactive_environments: list<string>
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
  | save Justfile

  for environment in $active_environments {
    if ($environment != generic) and (
      $"($environments_directory)/($environment)/Justfille"
      | path exists
    ) {
      
      $"mod ($environment) \"just/($environment).just\"" 
      | save --append Justfile
    }
  }
}
