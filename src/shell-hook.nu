use ./default/scripts/environment-common.nu get-environment-path

def get-environment-name [environment: any] {
  if (
    $environment
    | describe --detailed
    | get type
  ) == string {
    $environment
  } else {
    $environment.name
  }
}

def get-local-environment-directory [environment: any] {
  $".environments/(get-environment-name $environment)"
}

def copy-directory-files [directory: string] {
  if not ($directory | path exists) {
    return
  }

  for file in (ls --all $directory) {
    ^cp --recursive $file.name .
    chmod --recursive +w ($file.name | path basename)
  }
}

def copy-files [
  active_environments: list<record<name: string, features: list<string>>>
  inactive_environments: list<string>
] {
  for environment in $inactive_environments {
    let files_directories = (get-environment-path $environment files)
    let features_directory = (get-environment-path $environment features)

    let files_directories = if ($features_directory | path exists) {
      $files_directories
      | append (
          ls $features_directory
          | get name
          | each {$"($in)/files"}
        )
    } else {
      [$files_directories]
    }
    | where {path exists}

    for directory in $files_directories {
      for file in (ls --all $directory | get name) {
        rm --force --recursive ($file | path basename)
      }
    }
  }

  for environment in $active_environments {
    let features = (get-environment-path $environment.name features)

    if ($features | path exists) {
      for feature in (ls $features | get name) {
        if ($feature | path split | last) not-in $environment.features {
          let files = $"($feature)/files"

          if ($files | path exists) {
            for file in (ls --all --short-names $files | get name) {
              rm --force $file
            }
          }
        }
      }
    }
  }

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
          | each {get-environment-path $environment $"features/($in)/($file)"}
        )
      | where {path exists}
      | each {open | str trim}
    }
  | str trim
  | where {is-not-empty}
}

def generate-gitignore-file [
  active_environments: list<record<name: string, features: list<string>>>
] {
  mut comments = []
  mut previous_comment = []

  let gitignore_lines = try {
    open .gitignore
    | lines
    | append ["\n"]
  } catch {
    []
  }

  for line in $gitignore_lines {
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

def generate-helix-languages-file [
  active_environments: list<record<name: string, features: list<string>>>
] {
  ensure-directory-exists .helix

  let environment_languages = (
    generate-file $active_environments languages.toml
    | flatten
    | reduce {|a, b|  $a | merge deep --strategy append $b}
  )

  let languages = if (".helix/languages.toml" | path exists) {
    let languages = (
      open .helix/languages.toml
      | get language
      | append $environment_languages.language
      | uniq
    )

    mut merged_languages = []

    for language in $languages {
      if $language.name in $merged_languages.name {
        $merged_languages = (
          $merged_languages
          | where name != $language.name
          | append (
              $merged_languages
              | where name == $language.name
              | first
              | merge deep $language
            )
        )
      } else {
        $merged_languages = ($merged_languages | append $language)
      }
    }

    $environment_languages
    | update language ($merged_languages | uniq | sort-by name)
  } else {
    $environment_languages
    | update language ($environment_languages.language | uniq | sort-by name)
  }

  $languages
  | to toml
  | save --force .helix/languages.toml

  taplo format .helix/languages.toml out+err> /dev/null
}

def get-available-environments [] {
  ls --short-names $env.ENVIRONMENTS
  | where type == dir
  | get name
}

def set-default-check [
  name: string
  submodule_recipes: list<
    record<
      environment: string
      recipe: string
    >
  >
] {
  if not (
    (
      $submodule_recipes
      | where recipe == $name
      | length
    ) > 0
  ) {
    let text = (
      open Justfile
      | split row "\n\n"
      | where {
          $in != $"alias fmt := ($name)" and not (
            $in
            | str starts-with $"# ($name | str upcase) files"
          )
        }
      | str join "\n\n"
    )

    $text
    | save --force Justfile
  }
}

def generate-justfile-and-scripts [
  active_environments: list<record<name: string, features: list<string>>>
  inactive_environments: list<string>
] {
  for environment in $active_environments {
    let scripts = (get-environment-path $environment.name scripts)

    if ($scripts | path exists) {
      let local_scripts = (
        $"(get-local-environment-directory $environment)/scripts"
      )

      ensure-directory-exists $local_scripts

      for file in (fd --exclude tests "" $scripts | lines) {
        ^cp $file $local_scripts
      }
    }

    if ($environment.features | is-not-empty) {
      let features = (get-environment-path $environment.name features)

      if ($features | path exists) {
        let local_scripts = (
          $"(get-local-environment-directory $environment)/scripts"
        )

        ensure-directory-exists $local_scripts

        for file in (
          ls $features
          | get name
          | each {$"($in)/scripts"}
          | where {path exists}
          | each {ls $in | get name}
          | flatten
        ) {
          ^cp $file $local_scripts
        }
      }

    }
  }

  for environment in (
    $active_environments
    | where {$in.name != default}
  ) {
    let justfile = (get-environment-path $environment.name Justfile)

    let text = (
      $environment.features
      | each {
          let features_directory = (
            get-environment-path $environment.name $"features/($in)"
          )

          if ($features_directory | path exists) {
            fd Justfile $features_directory
            | lines
            | each {open}
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
      | save --force $"(get-local-environment-directory $environment)/Justfile"
    }
  }

  let non_default_environments = (
    ls --short-names .environments
    | where type == dir
    | where name != default
    | get name
    | uniq
    | sort
  )

  open (get-environment-path default Justfile)
  | append (
      $active_environments
      | each {
          |environment|

          $environment.features
          | each {
              let features_directory = (
                get-environment-path $environment.name $"features/($in)"
              )

              if ($features_directory | path exists) {
                fd --extension just "" $features_directory
                | lines
                | each {open}
                | flatten
              }
            }
        }
      | where {is-not-empty}
      | flatten
    )
  | append (
      $non_default_environments
      | each {
          |environment|

          let alias_file = (get-environment-path $environment aliases)

          let path = if (
            $alias_file
            | path exists
          ) {
            $alias_file
          } else {
            let alias_file = (
              ".environments"
              | path join (
                  $alias_file
                  | path dirname
                  | path basename
                )
              | path join aliases
            )

            if ($alias_file | path exists) {
              $alias_file
            }
          }

          if ($path | is-not-empty) {
            open $path
            | lines
            | each {
                let alias = ($in | split row "# alias " | last)

                $"[private]
@($alias) *args:
    just ($environment) {{ args }}
"
              }
          }
        }
      | where {is-not-empty}
    )
  | append (
      $non_default_environments
      | each {
          |environment|

          let justfile = (
            $"(get-local-environment-directory $environment)/Justfile"
          )

          if ($justfile | path exists) {
            $"mod ($environment) \"($justfile)\""
          }
        }
      | where {is-not-empty}
    )
  | flatten
  | str join "\n"
  | save --force Justfile

  let default_recipes = (
    just --summary
    | split row " "
    | where {"::" not-in $in}
  )

  let submodule_recipes = (
    ls .environments
    | get name
    | each {
        ls $in
        | where {($in.name | path parse | get stem) == Justfile}
        | get name
      }
    | flatten
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
          environment: ($justfile | path dirname | path parse | get stem)

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

  for recipe in [format lint] {
    set-default-check $recipe $submodule_recipes
  }

  let submodule_recipes = (
    $submodule_recipes
    | each {
        |recipe|

        if (
          (
            $default_recipes
            | wrap recipe
            | insert environment default
          ) ++ $submodule_recipes
          | where recipe == $recipe.recipe
          | length
        ) == 1 {
          let recipe_name = $recipe.recipe
          let environment = $recipe.environment

          let submodule_alias = (
            open $"(get-local-environment-directory $environment)/Justfile"
            | lines
            | where {str ends-with $":= ($recipe_name)"}
          )

          let submodule_alias = if ($submodule_alias | is-not-empty) {
            let alias = (
              $submodule_alias
              | first
              | split row " := "
              | split row "alias "
              | drop
              | where {is-not-empty}
            )

            if ($alias | is-not-empty) {
              let alias = ($alias | first)
              $"alias ($alias) := ($environment)::($recipe_name)"
            }
          }

          $submodule_alias
          | append $"alias ($recipe_name) := ($environment)::($recipe_name)"
        }
      }
  )

  if ($submodule_recipes | length) > 0 {
    "\n"
    | append $submodule_recipes
    | flatten
    | save --append Justfile
  }

  just --fmt --unstable
}

def run-hooks [
  active_environments: list<record<name: string, features: list<string>>>
  inactive_environments: list<string>
] {
  for environment in $active_environments {
    let hook_file = [(get-environment-path $environment.name hook.nu)]
    let features_directory = (get-environment-path $environment.name features)

    let hook_files = if ($features_directory | path exists) {
      $hook_file
      | append (
          ls --short-names $features_directory
          | get name
          | where {$in in $environment.features}
          | each {get-environment-path $environment.name $"features/($in)/hook.nu"}
          | flatten
        )
    } else {
      $hook_file
    }
    | where {path exists}

    for hook_file in $hook_files {
      nu $hook_file
    }
  }
}

def main [] {
  let active_environments = (
    [
      default
      git
      just
      markdown
      nix
      toml
      yaml
    ]
    | each {{name: $in}}
  )

  let active_environments = if (
    ".environments/environments.toml"
    | path exists
  ) {
    let configuration_file = (open .environments/environments.toml)

    if ("environments" in ($configuration_file | columns)) {
      $active_environments
      | append $configuration_file.environments
    } else {
      $active_environments
    }
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

        $environment
        | upsert features $features
      }
  )

  let inactive_environments = (
    get-available-environments
    | lines
    | where {$in not-in $active_environments.name}
  )

  for environment in (
    $active_environments
    | append $inactive_environments
  ) {
    rm --force --recursive (get-local-environment-directory $environment)
  }

  for environment in $active_environments {
    if not (
      [Justfile scripts]
      | each {get-environment-path $environment.name $in}
      | any {path exists}
    ) {
      continue
    }

    let directory = (get-local-environment-directory $environment)
    ensure-directory-exists $directory
    chmod --recursive +w $directory
  }

  copy-files $active_environments $inactive_environments
  generate-gitignore-file $active_environments
  generate-helix-languages-file $active_environments
  generate-justfile-and-scripts $active_environments $inactive_environments
  run-hooks $active_environments $inactive_environments
  chmod +w --recursive .environments
}
