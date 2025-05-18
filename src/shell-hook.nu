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

    let files_directory = $"($environments_directory)/($environment)/files"

    if ($files_directory | path exists) {
      for file in (ls $files_directory) {
        sudo rm --force --recursive ($file.name | path basename)
      }
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

  mut index = 0

  for environment in (
    $active_environments ++ ($local_justfiles | split row " ")
  ) {
    $"mod ($environment) \"just/($environment).just\"\n" 
    | save --append Justfile

    $index += 1
  }

  if $index > 0 {
    "\n"
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
      ^cp
        --recursive
        --update
        $"($environment_path)/scripts/($environment)"
        ./scripts
    )

    let files_directory = $"($environment_path)/files"

    # TODO: is it possible to distinguish between files that should always
    # be updated (like the lilypond helpers) and ones that shouldn't (like
    # pyproject.toml)? Should only the ones that can be overwritten be included
    # in this project, or is it worth distinguishing?
    if ($files_directory | path exists) {
      ^cp --recursive ($"($files_directory)/*" | into glob) ./
    }
  }

  let generic_recipes = (
    just --summary
    | split row " "
    | filter {|recipe| "::" not-in $recipe}
  )

  let submodule_recipes = (
    ls just
    | get name
    | each {
        |justfile|

        {
          environment: ($justfile | path parse | get stem)

          recipe: (
            just --justfile $justfile --summary
            | split row " "
          )
        }
      }
    | flatten
    | sort-by recipe
  )

  for recipe in $submodule_recipes {
    if (
      $generic_recipes ++ $submodule_recipes
      | find $recipe.recipe
      | length
    ) == 1 {
      $"alias ($recipe.recipe) := ($recipe.environment)::($recipe.recipe)\n"
      | save --append Justfile
    }
  }
}
