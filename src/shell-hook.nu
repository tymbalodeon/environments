def get-environment-path [
  environment: any
  path: string
] {
  let environment = if (
    $environment
    | describe --detailed
    | get type
  ) == string {
    $environment
  } else {
    $environment.name
  }

  $"($env.ENVIRONMENTS)/($environment)/($path)"
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

def remove-inactive-files [
  inactive_environments: list<string>
  directory: string
] {
  for environment in $inactive_environments {
    let files_directories = (get-environment-path $environment $directory)
    let features_directory = (get-environment-path $environment features)

    let files_directories = if ($features_directory | path exists) {
      $files_directories
      | append (
        ls $features_directory
        | get name
        | each {
            |feature|

            (
              get-environment-path
                $environment
                $"features/($feature)/($directory)"
            )
          }
        )
    } else {
      [$files_directories]
    }
    | where {path exists}

    for directory in $files_directories {
      for file in (ls $directory) {
        rm --force --recursive ($file.name | path basename)
      }
    }
  }
}

def copy-files [
  active_environments: list<record<name: string, features: list<string>>>
  inactive_environments: list<string>
] {
  remove-inactive-files $inactive_environments files

  for environment in $active_environments {
    copy-directory-files (get-environment-path $environment.name files)

    for feature in $environment.features {
      let features_directory = (
        get-environment-path $environment.name $"features/($feature)/files"
      )

      if ($features_directory | path exists) {
        copy-directory-files $features_directory
      }
    }
  }
}

def generate-file [
  active_environments: list<record<name: string, features: list<string>>>
  file: string
] {
  $active_environments
  | each {
      |environment|

      get-environment-path $environment.name $file
      | append (
          $environment.features
          | each {
              |feature|

              get-environment-path $environment $"features/($feature)/($file)"
            }
        )
      | where {path exists}
      | each {
          |file|

          open $file
          | str trim
        }
    }
  | str trim
  | where {is-not-empty}
}

def generate-gitignore-file [
  active_environments: list<record<name: string, features: list<string>>>
] {
  mut comments = []
  mut previous_comment = []

  for line in (open .gitignore | lines | append ["\n"]) {
    if ($line | str starts-with  "#") {
      $previous_comment = ($previous_comment | append $line)
    } else {
      $comments = (
        $comments
        | append {
            comment: (
              $previous_comment
              | str join "\n"
            )

            line: $line
        }
      )

      $previous_comment = []
    }
  }

  let comments = $comments

  generate-file $active_environments .gitignore
  | flatten
  | each {lines}
  | flatten
  | append $comments.line
  | where {$in | str trim | is-not-empty}
  | uniq
  | sort
  | each {
      |line|

      if $line in $comments.line {
        let comment = (
          $comments
          | where line == $line
          | get comment
          | first
        )

        if ($comment | is-not-empty) {
          $comment
          | append $line
          | str join "\n"
        } else {
          $line
        }
      } else {
        $line
      }
    }
  | to text
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

def merge-environments-and-local-file [
  active_environments: list<record<name: string, features: list<string>>>
  environment_file: string
  local_file?: string
 ] {
  let local_file = if ($local_file | is-empty) {
    $environment_file
  } else {
    $local_file
  }

  generate-file $active_environments $environment_file
  | flatten
  | reduce {|a, b| $a | merge deep --strategy append $b}
  | merge deep --strategy overwrite (open $local_file)
}

def generate-helix-languages-file [
  active_environments: list<record<name: string, features: list<string>>>
] {
  # TODO: how to handle duplicate names (exact duplicates are removed, but
  # should it remove duplicates with the same name only and if so, which to
  # privilege--the environment or the local?)
  ensure-directory-exists .helix

  (
    merge-environments-and-local-file
      $active_environments
      languages.toml
      .helix/languages.toml
  )
  | to toml
  | save --force .helix/languages.toml

  taplo format .helix/languages.toml
}

def get-available-environments [] {
  ls --short-names $env.ENVIRONMENTS
  | where type == dir
  | get name
}

def generate-justfile-and-scripts [
  active_environments: list<record<name: string, features: list<string>>>
  inactive_environments: list<string>
] {
  let local_justfiles = (
    ls --short-names just
    | get name
    | path parse
    | get stem
    | where {$in not-in (get-available-environments)}
  )

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

  for file in (ls ("scripts/*" | into glob) | where type == file) {
    rm --force $file.name
  }

  let script_files = (
    $active_environments
    | each {
        |environment|

        {
          source: (get-environment-path $environment scripts)
          environment: $environment.name
        }
        | append (
            $environment.features
            | each {
                |feature|

                let feature_path = (
                  $"(get-environment-path $environment $"features/($feature)")"
                )

                if ($feature_path | path exists) {
                  {
                    source: $"($feature_path)/scripts"

                    environment: (
                      if ($"($feature)/Justfile" | path exists) {
                        $environment.name
                      } else {
                        "generic"
                      }
                    )
                  }
                }
              }
          )
        | where {is-not-empty}
        | flatten
        | where {$in.source | path exists}
        | each {
            |item|

            {
              path: (
                fd --exclude tests --type file "" $item.source
                | lines
              )

              environment: $item.environment
            }
          }
        | flatten
      }
    | flatten
  )

  ensure-directory-exists scripts

  for file in $script_files {
    let local_directory = if $file.environment == generic {
      "scripts"
    } else {
      let local_directory = $"scripts/($file.environment)"
      ensure-directory-exists $local_directory
      $local_directory
    }

    let basename = ($file.path | path basename)
    ^cp --recursive $file.path $"($local_directory)/($basename)"
  }

  chmod --recursive +w scripts
  ensure-directory-exists just

  for environment in (
    $active_environments
    | where {$in.name != generic}
  ) {
    let justfile = (get-environment-path $environment Justfile)

    let text = (
      $environment.features
      | each {
          |feature|

          let features_directory = (
            get-environment-path $environment $"features/($feature)"
          )

          if ($features_directory | path exists) {
            fd Justfile $features_directory
            | lines
            | each {|file| open $file}
            | flatten
          }
        }
      | where {is-not-empty}
    )

    let text = if ($justfile | path exists) {
      open $justfile
      | append $text
    } else {
      $text
    }

    if ($text | is-not-empty) {
      $text
      | to text --no-newline
      | save --force $"just/($environment.name).just"
    }
  }

  chmod --recursive +w just

  open (get-environment-path generic Justfile)
  | append (
      $active_environments
      | each {
          |environment|

          $environment.features
          | each {
              |feature|

              let features_directory = (
                get-environment-path $environment $"features/($feature)"
              )

              if ($features_directory | path exists) {
                fd --extension just "" $features_directory
                | lines
                | each {|file| open $file}
                | flatten
              }
            }
        }
      | where {is-not-empty}
      | flatten
    )
  | append (
      (
        $active_environments
        | get name
        | where {$in != generic}
      ) ++ $local_justfiles
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
  | flatten
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

def get-environment-pre-commit-hooks [
  environment: record<name: string, features: list<string>>
] {
  let pre_commit_config = (
    get-environment-path $environment.name .pre-commit-config.yaml
  )

  if not ($pre_commit_config | path exists) {
    return
  }

  if $environment.name == generic {
    open $pre_commit_config
    | to yaml
  } else {
    $"# ($environment.name)\n"
    | append (
        open $pre_commit_config
        | get repos
        | to yaml
      )
    | str join
  }
}

def generate-pre-commit-config-file [
  active_environments: list<record<name: string, features: list<string>>>
  inactive_environments: list<string>
] {
  # TODO: allow different environments to include the same pre-commit checks,
  # but don't duplicate when combined into one (see javascript/typescript)
  (
    merge-environments-and-local-file
      $active_environments
      .pre-commit-config.yaml
  )
  | to yaml
  | save --force .pre-commit-config.yaml

  yamlfmt .pre-commit-config.yaml
}

def generate-template-files [
  active_environments: list<record<name: string, features: list<string>>>
  inactive_environments: list<string>
] {
  remove-inactive-files $inactive_environments templates

  for environment in $active_environments {
    let templates_directory = (get-environment-path $environment.name templates)
    let features_directory = (get-environment-path $environment.name features)

    let template_directories = if ($features_directory | path exists) {
      $templates_directory
      | append (
        ls $features_directory
        | get name
        | each {
            |feature|

            (
              get-environment-path
                $environment
                $"features/($feature)/templates"
            )
          }
        )
    } else {
      [$templates_directory]
    }
    | where {path exists}

    mkdir tera

    for directory in $template_directories {
      let context_source = $"($directory)/context.toml"
      let local_context_file = $"tera/($environment.name).toml"

      if not ($local_context_file | path exists) {
        if ($context_source | path exists) {
          ^cp $context_source $local_context_file
          chmod +w $local_context_file
        } else {
          touch $local_context_file
        }
      }

      for file in (
        ls $directory
        | get name
        | where {not ($in | str ends-with context.toml)}
      ) {
        let local_file = ($file | path basename | str replace ".templ" "")
        let text = (tera --template $file $local_context_file)
        let is_toml = (($local_file | path parse | get extension) == toml)

        let text = if $is_toml {
          if ($local_file | path exists) {
            open $local_file
            | merge deep --strategy overwrite (
              $text
              | from toml
            )
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
    [
      generic
      git
      nix
      toml
      yaml
    ]
    | each {|environment| {name: $environment}}
  )

  let active_environments = if (".environments.toml" | path exists) {
    $active_environments
    | append (open .environments.toml).environments
  } else {
    $active_environments
  }

  let active_environments = (
    $active_environments
    | uniq
    | sort
    | each {
        |environment|

        let features = if "features" in ($environment | columns) {
          $environment.features
        } else {
          []
        }

        $environment | upsert features $features
      }
  )

  let inactive_environments = (
    get-available-environments
    | lines
    | where {$in not-in $active_environments.name}
  )

  copy-files $active_environments $inactive_environments
  generate-gitignore-file $active_environments
  generate-helix-languages-file $active_environments
  generate-justfile-and-scripts $active_environments $inactive_environments
  generate-pre-commit-config-file $active_environments $inactive_environments
  generate-template-files $active_environments $inactive_environments
}
