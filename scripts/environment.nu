#!/usr/bin/env nu

def get_base_url [] {
  "https://api.github.com/repos/tymbalodeon/environments/contents/src"
}

def get_files [url: string] {
  let contents = (http get $url)

  $contents
  | filter {|item| $item.type == "file"}
  | append (
      $contents
      | filter {|item| $item.type == "dir"}
      | par-each {|directory| get_files $directory.url}
    )
  | flatten
}

def get_environment_files [environment: string] {
  get_files ([(get_base_url) $environment] | path join)
  | update path {
      |row|

      $row.path
      | str replace $"src/($environment)/" ""
    }
  | filter {
      |row|

      let path = ($row.path | path parse)

      $path.extension != "lock" and "tests" not-in (
        $path
        | get parent
      )
  }
}

def copy_files [
  environment: string
  environment_files: table<
    name: string,
    path: string,
    sha: string,
    size: int,
    url: string,
    html_url: string,
    git_url: string,
    download_url: string,
    type: string,
    self: string,
    git: string,
    html: string
  >
] {
  let environment_scripts_directory = ([scripts $environment] | path join)

  rm -rf $environment_scripts_directory

  $environment_files
  | filter {
      |row|

      $row.name not-in [.gitignore .pre-commit-config.yaml Justfile]
    }
  | select path download_url
  | par-each {
      |file|

      let parent = ($file.path | path parse | get parent)

      if ($parent | is-not-empty) {
        mkdir $parent
      }

      print $"Downloading ($file.path)..."

      http get $file.download_url
      | save --force $file.path
  }
}

def get_environment_file_url [
  environment_files: table<
    name: string,
    path: string,
    sha: string,
    size: int,
    url: string,
    html_url: string,
    git_url: string,
    download_url: string,
    type: string,
    self: string,
    git: string,
    html: string
  >
  file: string
] {
  try {
    $environment_files
    | where path == $file
    | first
    | get download_url
  }
}

def get_environment_file [
  environment_files: table<
    name: string,
    path: string,
    sha: string,
    size: int,
    url: string,
    html_url: string,
    git_url: string,
    download_url: string,
    type: string,
    self: string,
    git: string,
    html: string
  >
  file: string
] {
  let url = (get_environment_file_url $environment_files $file)

  if ($url | is-empty) {
    return ""
  }

  http get $url
}

def download_environment_file [
  environment_files: table<
    name: string,
    path: string,
    sha: string,
    size: int,
    url: string,
    html_url: string,
    git_url: string,
    download_url: string,
    type: string,
    self: string,
    git: string,
    html: string
  >
  file: string
  extension?: string
] {
  let temporary_file = if ($extension | is-not-empty) {
    mktemp --tmpdir --suffix $".($extension)"
  } else {
    mktemp --tmpdir
  }

  let file_contents = (
    get_environment_file $environment_files $file
  )

  $file_contents
  | save --force $temporary_file

  $temporary_file
}

def get_recipes [justfile: string] {
  (
    just
      --justfile $justfile
      --summary
    | split row " "
  )
}

def create_environment_recipe [environment: string recipe: string] {
  let documentation = $"# Alias for `($environment) ($recipe)`"
  let declaration = $"@($recipe) *args:"
  let content = $"    just ($environment) ($recipe) {{ args }}"

  [$documentation $declaration $content]
  | str join "\n"
}

export def merge_justfiles [
  environment: string
  main_justfile: string
  environment_justfile: string
] {
  if $environment == "generic" {
    return (
      open $environment_justfile
      | append (
          open $main_justfile
          | split row "mod"
          | drop nth 0
          | prepend mod
          | str join
        )
      | to text
    )
  }

  let unique_environment_recipes = (
    get_recipes $environment_justfile
    | filter {
        |recipe|

        $recipe not-in (
          get_recipes $main_justfile
        )
    }
  )

  if ($unique_environment_recipes | is-empty) {
    return
  }

  open $main_justfile
  | append (
      $"mod ($environment) \"just/($environment).just\""
      | append (
          $unique_environment_recipes
          | each {
              |recipe|

              create_environment_recipe $environment $recipe
            }
        )
      | str join "\n\n"
    )
  | to text
}

def save_file [contents: string filename: string] {
  $contents 
  | save --force $filename

  print $"Updated ($filename)"
}

def save_justfile [justfile: string] {
  save_file $justfile Justfile
}

def copy_justfile [
  environment: string
  environment_files: table<
    name: string,
    path: string,
    sha: string,
    size: int,
    url: string,
    html_url: string,
    git_url: string,
    download_url: string,
    type: string,
    self: string,
    git: string,
    html: string
  >
] {
  let environment_justfile_name = if $environment == "generic" {
    "Justfile"
  } else {
    $"just/($environment).just"
  }

  let environment_justfile_file = (
    download_environment_file
      $environment_files
      $environment_justfile_name
  )

  let environment_justfile = (open $environment_justfile_file)

  if (
    $environment_justfile
    | is-not-empty
  ) {
    let merged_justfile = (
      merge_justfiles
        $environment
        Justfile
        $environment_justfile_file
    )

    if ($merged_justfile | is-not-empty) {
      save_justfile $merged_justfile
    }
  }

  rm $environment_justfile_file
}

def merge_generic [main: string environment: string] {
  $environment
  | append (
      $main    
      | split row "#"
      | drop nth 0
    )
}

export def merge_gitignores [
  main_gitignore: string
  new_environment_name: string
  environment_gitignore: string
] {
  let merged_gitignore = if $new_environment_name == "generic" {
    merge_generic $main_gitignore $environment_gitignore
  } else {
    $main_gitignore
    | append (
        $"\n# ($new_environment_name)\n\n($environment_gitignore)"
      )
  }

  $merged_gitignore
  | to text
}

def get_environment_name [
  environment_files: table<
    name: string,
    path: string,
    sha: string,
    size: int,
    url: string,
    html_url: string,
    git_url: string,
    download_url: string,
    type: string,
    self: string,
    git: string,
    html: string
  >
] {
  $environment_files
  | get download_url
  | path parse
  | get parent
  | path basename
  | first
}

def save_gitignore [gitignore: string] {
  save_file $gitignore .gitignore
}

def copy_gitignore [
  environment_files: table<
    name: string,
    path: string,
    sha: string,
    size: int,
    url: string,
    html_url: string,
    git_url: string,
    download_url: string,
    type: string,
    self: string,
    git: string,
    html: string
  >
] {
  let environment_gitignore = (
    get_environment_file $environment_files ".gitignore"
  )

  if ($environment_gitignore | is-not-empty) {
    let new_environment_name = (get_environment_name $environment_files)

    save_gitignore (
      merge_gitignores
        (open .gitignore)
        $new_environment_name
        $environment_gitignore
    )
  }
}

def get_pre_commit_config_repos [config: record<repos: list>] {
  $config
  | get repos
  | to yaml
}

export def merge_pre_commit_configs [
  main_config: record<repos: list>
  new_environment_name: string
  environment_config: record<repos: list>
] {
  let main_config = (get_pre_commit_config_repos $main_config)
  let environment_config = (get_pre_commit_config_repos $environment_config)

  let merged_pre_commit_config = if $new_environment_name == "generic" {
    merge_generic $main_config $environment_config
  } else {
    $main_config
    | append $"# ($new_environment_name)"
    | append $environment_config
  }

  "repos:\n"
  | append $merged_pre_commit_config
  | to text
  | yamlfmt -
}

export def save_pre_commit_config [config: string] {
  save_file $config .pre-commit-config.yaml
}

def copy_pre_commit_config [
  environment_files: table<
    name: string,
    path: string,
    sha: string,
    size: int,
    url: string,
    html_url: string,
    git_url: string,
    download_url: string,
    type: string,
    self: string,
    git: string,
    html: string
  >
] {
  let new_environment_name = (get_environment_name $environment_files)

  let environment_config = (
    get_environment_file $environment_files ".pre-commit-config.yaml"
  )

  save_pre_commit_config (
    merge_pre_commit_configs 
      (open .pre-commit-config.yaml)
      $new_environment_name 
      $environment_config
  ) 
}

def reload_environment [
  environment_files: table<
    name: string,
    path: string,
    sha: string,
    size: int,
    url: string,
    html_url: string,
    git_url: string,
    download_url: string,
    type: string,
    self: string,
    git: string,
    html: string
  >
] {
  if (
    $environment_files
    | filter {
        |file|

        (
          $file.name
          | path parse
          | get extension
        ) == "nix"
      }
    | is-not-empty
  ) {
    just init
  }
}

def "main add" [
  ...environments: string
] {
  for environment in $environments {
    let environment_files = (get_environment_files $environment)

    copy_files $environment $environment_files
    copy_justfile $environment $environment_files
    copy_gitignore $environment_files
    copy_pre_commit_config $environment_files

    reload_environment $environment_files

    print $"Added ($environment) environment..."
  }
}

def "main list" [
  environment?: string
  path?: string
] {
  let url = (get_base_url)

  if ($environment | is-empty) {
    return (
      http get $url
      | get name
      | to text
    )
  }

  let files = (
    get_files (
      [$url $environment]
      | path join
    )
  )

  if ($path | is-empty) {
    return (
      $files
      | get path
      | str replace $"src/($environment)/" ""
      | to text
    )
  }

  let full_path = (
    [src $environment $path]
    | path join
  )

  if $full_path in ($files | get path) {
    let file_url = (
      $files
      | where path == $full_path
      | get download_url
      | first
    )

    return (http get $file_url)
  }

  $files
  | where path =~ $path
  | get path
  | str replace $"src/($environment)/" ""
  | to text
}

def get_installed_environments [] {
  ls nix
  | get name
  | path parse
  | get stem
  | filter {|environment| $environment in (main list)}
}

def get_environments [
  environments: list<string>
  installed_environments: list<string>
] {
  if ($environments | is-empty) {
    "generic"
    | append $installed_environments
  } else {
    $environments
  }
}

def remove_environment_file [environment: string type: string] {
  rm -f $"($type)/($environment).($type)"

  if (ls $type | length) == 0 {
    rm $type
  }
}

def remove_files [environment: string] {
  remove_environment_file $environment nix
  rm -rf $"scripts/($environment)"
}

def remove_environment_from_justfile [environment: string] {
  let filtered_justfile = try {
    let environment_mod = (
      "mod "
      | append (
          open Justfile
          | split row "mod"
          | str trim
          | filter {|recipes| $recipes | str starts-with $environment}
          | first
        )
      | str join
    )

    let filtered_justfile = (
      open Justfile
      | str replace $environment_mod ""
    )

    $filtered_justfile
    | lines
    | str join "\n"
  } catch {
    null
  }

  remove_environment_file $environment just

  $filtered_justfile
}

def remove_environment_from_gitignore [environment: string] {
  let filtered_gitignore = (
    open .gitignore
    | split row "# "
    | filter {
        |item|

        not (
          $item
          | str starts-with $environment
        )
      }
    | str trim
    | to text
  )
}

def remove_environment_from_pre_commit_config [environment: string] {
  open --raw .pre-commit-config.yaml
  | split row "# "
  | filter {
      |item|

      not (
        $item
        | str starts-with $environment
      )
    }
  | str join "#"
  | str join
  | yamlfmt -
}

def "main remove" [...environments: string] {
  let installed_environments = (get_installed_environments)

  let environments = (
    get_environments $environments $installed_environments
    | filter {
        |environment| 
        
        $environment != "generic" and (
          $environment in $installed_environments
        )
      }
  )

  for environment in $environments {
    print $"Removing ($environment)..."

    let environment_files = (get_environment_files $environment)

    remove_files $environment

    let filtered_justfile = (remove_environment_from_justfile $environment)

    if $filtered_justfile != null {
      save_justfile $filtered_justfile
    }

    (
      save_gitignore
        (remove_environment_from_gitignore $environment)
    )

    (
      save_pre_commit_config 
        (remove_environment_from_pre_commit_config $environment)
    )
  }
}

def "main update" [
  ...environments: string
] {
  let environments = (
    get_environments $environments (get_installed_environments)
  )

  main add ...$environments
}

def main [
  environment?: string
] {
  get_installed_environments
  | str join
}
