def get-environment-gitignore [
  environment: string
  environments_directory: string
] {
    let gitignore_file = $"($environments_directory)/($environment)/.gitignore"

    if not ($gitignore_file | path exists) {
      return
    }

    if $environment == generic {
      open $gitignore_file
    } else {
      $"# ($environment)"
      | append (open $gitignore_file | str trim)
      | to text
    }
}

def get-environment-pre-commit-hooks [
  environment: string
  environments_directory: string
] {
    let pre_commit_config = $"(
      $environments_directory
    )/($environment)/.pre-commit-config.yaml"

    if not ($pre_commit_config | path exists) {
      return
    }

    if $environment == generic {
      open --raw $pre_commit_config
    } else {
      $"# ($environment)"
      | append (
          open $pre_commit_config
          | get repos
          | to yaml
        )
      | to text
    }
}

def main [
  --active-environments: string
  --environments-directory: string
  --inactive-environments: string
  --local-justfiles: string
] {
  let active_environments = ($active_environments | split row " ")
  let inactive_environments = ($inactive_environments | split row " ")

  for environment in $inactive_environments {
    rm --force $"just/($environment).just"
    rm --force --recursive $"scripts/($environment)"

    let files_directory = $"($environments_directory)/($environment)/files"

    if ($files_directory | path exists) {
      for file in (ls $files_directory) {
        # FIXME
        if ($file.name | path basename) == "pyproject.toml" {
          continue
        }

        rm --force --recursive ($file.name | path basename)
      }
    }
  }

  for file in (ls ("scripts/*" | into glob) | where type == file) {
    rm $file.name
  }

  for file in (
    fd --exclude tests --type file "" $"($environments_directory)/generic/scripts"
    | lines
  ) {
    cp $file scripts
  }

  open $"($environments_directory)/generic/Justfile"
  | append "\n"
  | str join
  | save --force Justfile

  let active_environments = (
    $active_environments
    | filter {
        |environment|

        $environment != generic and (
          $"($environments_directory)/($environment)/Justfile"
          | path exists
        )
      }
  )

  mut index = 0

  let local_justfiles = if $local_justfiles == none {
    ""
  } else {
    $local_justfiles
  }

  for environment in (
    $active_environments ++ (
      $local_justfiles
      | split row " "
      | where {is-not-empty}
    )
    | uniq
    | sort
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
        $"just/($environment).just"
    )

    let scripts_directory = $"scripts/($environment)"

    if ($scripts_directory | path exists) {
      rm --force --recursive $scripts_directory
    }

    mkdir $scripts_directory

    let scripts = ($"($environment_path)/scripts/*" | into glob)

    if (ls $scripts | is-not-empty) {
      (
        ^cp
          --recursive
          --update
          $scripts
          $"scripts/($environment)"
      )
    }


    let files_directory = $"($environment_path)/files"

    # TODO: is it possible to distinguish between files that should always
    # be updated (like the lilypond helpers) and ones that shouldn't (like
    # pyproject.toml)? Should only the ones that can be overwritten be included
    # in this project, or is it worth distinguishing?
    if ($files_directory | path exists) {
      for file in (ls $files_directory) {
        ^cp --recursive $file.name .
        chmod --recursive +w ($file.name | path basename)
      }
    }
  }

  chmod --recursive +w just
  chmod --recursive +w scripts

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
    | where {$in.recipe | is-not-empty}
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

  let local_gitignore = (
    open .gitignore
    | split row "\n\n"
    | filter {
        |section|

        ($section | str starts-with  "#") and (
          ($section | lines | first | str replace "# " "") not-in (
            $active_environments ++ $inactive_environments
            | append generic
          )
        )
      }
  )

  get-environment-gitignore generic $environments_directory
  | save --force .gitignore

  if ($local_gitignore | is-not-empty) {
    "\n"
    | append $local_gitignore
    | append "\n"
    | str join
    | save --append .gitignore
  }

  for environment in $active_environments {
    let environment_gitignore = (
      get-environment-gitignore $environment $environments_directory
    )

    if ($environment_gitignore | is-not-empty) {
      "\n"
      | append $environment_gitignore
      | str join
      | save --append .gitignore
    }
  }

  let local_pre_commit_config = (
    open --raw .pre-commit-config.yaml
    | split row "# "
    | drop nth 0
    | filter {
        |section|

        let first_line = ($section | lines | first)

        ($first_line | rg "^[a-z]" | is-not-empty) and $first_line not-in (
          $active_environments ++ $inactive_environments
          | append generic
        )
      }
    | each {
        |section|

        let lines = ($section | lines)

        $"# ($lines | first)\n(
          $lines
          | drop nth 0
          | to text
          | from yaml
          | to yaml
        )"
        | lines
        | each {|line| $"  ($line)"}
        | to text
      }
  )

  get-environment-pre-commit-hooks generic $environments_directory
  | save --force .pre-commit-config.yaml

  if ($local_pre_commit_config | is-not-empty) {
    $local_pre_commit_config
    | str join
    | save --append .pre-commit-config.yaml
  }

  for environment in $active_environments {
    let environment_pre_commit_config = (
      get-environment-pre-commit-hooks $environment $environments_directory
    )

    if ($environment_pre_commit_config | is-not-empty) {
      "\n"
      | append $environment_pre_commit_config
      | str join
      | save --append .pre-commit-config.yaml
    }
  }

  yamlfmt .pre-commit-config.yaml
}
