def generate-environments-file [] {
  if (".environments.toml" | path exists) {
    {
      environments: (
        open $"($env.ENVIRONMENTS)/generic/.environments.toml"
        | get environments
        | append (open .environments.toml).environments
        | uniq
        | sort
      )
    }
    | save --force .environments.toml

    taplo format .environments.toml
  } else {
    ^cp $"($env.ENVIRONMENTS)/generic/.environments.toml" .
    chmod +w .environments.toml
  }
}

def copy-directory-files [directory: string] {
  if not ($directory | path exists) {
    return
  }

  for file in (ls $directory) {
    ^cp --recursive $file.name .
    chmod --recursive +w ($file.name | path basename)
  }
}

def copy-files [
  active_environments: list<string>
  inactive_environments: list<string>
] {
  for inactive_environment in $inactive_environments {
    let files_directory = (
      $"($env.ENVIRONMENTS)/($inactive_environment)/files"
    )

    if ($files_directory | path exists) {
      for file in (ls $files_directory) {
        rm --force --recursive ($file.name | path basename)
      }
    }
  }

  for environment in $active_environments {
    copy-directory-files $"($env.ENVIRONMENTS)/($environment)/files"
  }
}

def get-environment-gitignore [environment: string] {
  let gitignore_file = $"($env.ENVIRONMENTS)/($environment)/.gitignore"

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

def generate-gitignore-file [
  active_environments: list<string>
  inactive_environments: list<string>
] {
  let local_gitignore = if (".gitignore" | path exists) {
    open .gitignore
    | split row "\n\n"
    | filter {
        |section|

        ($section | str starts-with  "#") and (
          ($section | lines | first | str replace "# " "") not-in (
            just env list
            | lines
          )
        )
      }
    | each {|section| $"($section)\n"}
  } else {
    []
  }

  $active_environments
  | each {get-environment-gitignore $in}
  | append $local_gitignore
  | where {is-not-empty}
  | str join "\n"
  | save --force .gitignore
}

def ensure-directory-exists [name: string] {
  if not ($name | path exists) {
    ^mkdir --parents $name
  } else if ($name | path type) == file {
    rm $name
    ^mkdir --parents $name
  }

  chmod --recursive +w $name
}

def generate-helix-languages-file [active_environments: list<string>] {
  # TODO: allow project-specific helix settings to be picked up here
  ensure-directory-exists .helix

  $active_environments
  | each {
      |environment|

      let languages_file = (
        $"($env.ENVIRONMENTS)/($environment)/languages.toml"
      )

      if ($languages_file | path exists) {
        open --raw $languages_file
      }
    }
  | str join "\n"
  | save --force .helix/languages.toml
}

def generate-justfile-and-scripts [
  active_environments: list<string>
  inactive_environments: list<string>
] {
  for environment in $inactive_environments {
    let environment_justfile = $"just/($environment).just"

    if ($environment_justfile | path exists) {
      rm --force $environment_justfile
    }

    let environment_scripts = $"scripts/($environment)"

    if ($environment_scripts | path exists) {
      rm --force --recursive $environment_scripts
    }
  }

  ensure-directory-exists scripts

  try {
    for file in (ls ("scripts/*" | into glob) | where type == file) {
      rm $file.name
    }
  }

  let scripts_directories = (
    $active_environments
    | each {
        |environment|

        let scripts_directory = (
          $"($env.ENVIRONMENTS)/($environment)/scripts"
        )

        {
          environment: $environment

          files: (
            if ($scripts_directory | path exists) {
              fd --exclude tests --type file "" $scripts_directory
              | lines
            } else {
              []
            }
          )
        }
      }
    | where {$in.files | is-not-empty}
    | flatten
  )

  for directory in $scripts_directories {
    let local_directory = if $directory.environment == generic {
      "scripts"
    } else {
      let local_directory = $"scripts/($directory.environment)"
      ensure-directory-exists $local_directory
      $local_directory
    }

    for file in $directory.files {
      ^cp --recursive $file $"($local_directory)/($file | path basename)"
    }
  }

  chmod --recursive +w scripts
  ensure-directory-exists just

  for environment in ($active_environments | where {$in != generic}) {
    let justfile = (
      $"($env.ENVIRONMENTS)/($environment)/Justfile"
    )

    if ($justfile | path exists) {
      ^cp $justfile $"just/($environment).just"
    }
  }

  chmod --recursive +w just

  let local_justfiles = (
    ls --short-names just
    | get name
    | path parse
    | get stem
    | where {$in not-in (just env list | lines)}
  )

  open $"($env.ENVIRONMENTS)/generic/Justfile"
  | append (
      ($active_environments | where {$in != generic}) ++ $local_justfiles
      | uniq
      | sort
      | each {
          |environment|

          let justfile = $"just/($environment).just"

          if ($justfile | path exists) {
            $"mod ($environment) \"($justfile)\""
          }
        }
      | where {is-not-empty}
    )
  | str join "\n"
  | save --force Justfile

  let generic_recipes = (
    just --summary
    | split row " "
    | filter {|recipe| "::" not-in $recipe}
  )

  let submodule_recipes = (
    (ls just).name
    | each {
        |justfile|

        let system_specific_recipes = (
          rg --multiline '\[macos\][^#]*' $justfile
          | rg --invert-match "^ {4}"
          | split row --regex '\[.*\]'
          | str trim
          | where {is-not-empty}
          | str replace "@" ""
          | each {split row " " | first}
        )

        {
          environment: ($justfile | path parse | get stem)

          recipe: (
            just --justfile $justfile --summary
            | split row " "
            | where {$in not-in $system_specific_recipes}
          )
        }
      }
    | flatten
    | where {($in.recipe | is-not-empty)}
    | sort-by recipe
  )

  let submodule_recipes = (
    $submodule_recipes
    | each {
        |recipe|

        if (
          (
            $generic_recipes
            | wrap recipe
            | insert environment generic
          ) ++ $submodule_recipes
          | where recipe == $recipe.recipe
          | length
        ) == 1 {
          $"alias ($recipe.recipe) := ($recipe.environment)::($recipe.recipe)"
        }
      }
  )

  if ($submodule_recipes | length) > 0 {
    "\n"
    | append $submodule_recipes
    | save --append Justfile
  }

  just --fmt --unstable
}

def get-environment-pre-commit-hooks [environment: string] {
  let pre_commit_config = $"(
    $env.ENVIRONMENTS
  )/($environment)/.pre-commit-config.yaml"

  if not ($pre_commit_config | path exists) {
    return
  }

  if $environment == generic {
    open $pre_commit_config
    | to yaml
  } else {
    $"# ($environment)\n"
    | append (
        open $pre_commit_config
        | get repos
        | to yaml
      )
    | str join
  }
}

# FIXME
def generate-pre-commit-config-file [
  active_environments: list<string>
  inactive_environments: list<string>
] {
  # TODO: allow different environments to include the same pre-commit checks,
  # but don't duplicate when combined into one (see javascript/typescript)

  let local_pre_commit_config = if (".pre-commit-config.yaml" | path exists) {
    open --raw .pre-commit-config.yaml
    | split row "# "
    | drop nth 0
    | filter {
        |section|

        let first_line = ($section | lines | first)

        ($first_line | rg "^[a-z]" | is-not-empty) and $first_line not-in (
          just env list
          | lines
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
      }
  } else {
    []
  }

  $active_environments
  | each {get-environment-pre-commit-hooks $in}
  | append $local_pre_commit_config
  | where {is-not-empty}
  | str join
  | save --force .pre-commit-config.yaml

  yamlfmt .pre-commit-config.yaml
}

def generate-template-files [
  active_environments: list<string>
  inactive_environments: list<string>
] {
  for environment in $inactive_environments {
    let templates_directory = (
      $"($env.ENVIRONMENTS)/($environment)/templates"
    )

    if ($templates_directory | path exists) {
      for file in (ls $templates_directory) {
        rm --force --recursive ($file.name | path basename)
      }
    }
  }

  for environment in $active_environments {
    let templates_directory = $"($env.ENVIRONMENTS)/($environment)/templates"

    if ($templates_directory | path exists) {
      mkdir tera
      let context_source = $"($templates_directory)/context.toml"
      let local_context_file = $"tera/($environment).toml"

      if not ($local_context_file | path exists) {
        if ($context_source | path exists) {
          ^cp $context_source $local_context_file
          chmod +w $local_context_file
        } else {
          touch $local_context_file
        }
      }

      for file in (
        ls $templates_directory
        | get name
        | where {not ($in | str ends-with context.toml)}
      ) {
        let local_file = ($file | path basename | str replace ".templ" "")
        let text = (tera --template $file $local_context_file)
        let is_toml = (($local_file | path parse | get extension) == toml)

        let text = if $is_toml {
          if ($local_file | path exists) {
            $text
            | from toml
            | merge deep (open $local_file)
          } else {
            $text
          }
        } else {
          $text
        }

        $text
        | save --force $local_file

        if $is_toml {
          taplo format $local_file
        }
      }
    }
  }
}

def main [] {
  let active_environments = (
    open .environments.toml
    | get environments
    | uniq
  )

  let inactive_environments = (
    just env list
    | lines
    | where {$in not-in (open .environments.toml | get environments)}
  )

  generate-environments-file
  copy-files $active_environments $inactive_environments
  generate-gitignore-file $active_environments $inactive_environments
  generate-helix-languages-file $active_environments
  generate-justfile-and-scripts $active_environments $inactive_environments
  generate-pre-commit-config-file $active_environments $inactive_environments
  generate-template-files $active_environments $inactive_environments
}
