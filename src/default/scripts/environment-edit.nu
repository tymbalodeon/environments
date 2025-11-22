use environment-activate.nu
use environment-common.nu open-configuration-file

def filter-to-local-files [files: string] {
  let default_environments = (
    get-available-environments --exclude-local
    | get name
  )

  $files
  | lines
  | where {($in | path split | get 1) not-in $default_environments}
}

export def justfile [] {
  let justfiles = (filter-to-local-files (fd Justfile .environments))

  if ($justfiles | is-empty) {
    return
  }

  let justfile = if ($justfiles | length) > 1 {
    $justfiles
    | fzf
  } else {
    $justfiles
    | first
  }

  ^$env.EDITOR $justfile
}

export def "helix languages" [] {
  ^$env.EDITOR .helix/languages.toml
}

export def helix [] {
  ^$env.EDITOR .helix
}

export def recipe [recipe?: string] {
  let recipes = (filter-to-local-files (fd --extension nu "" .environments))

  if ($recipes | is-empty) {
    return
  }

  let recipe = if ($recipe | is-empty) {
    $recipes
    | to text
    | fzf
  } else {
    let recipe = (
      $recipes
      | find --no-highlight $recipe
    )

    if ($recipe | is-empty) {
      return
    }

    if ($recipe | length) > 1 {
      $recipe
      | to text
      | fzf
    } else {
      $recipe
      | first
    }
  }

  ^$env.EDITOR $recipe
}

export def shell [] {
  let shells = (fd --extension nix shell .environments | lines)

  let shell = if ($shells | is-empty) {
    let local_environment = $".environments/(pwd | path split | last)"
    mkdir $local_environment
    let shell = $"($local_environment)/shell.nix"

    "{pkgs,...}: {
  packages = with pkgs; [

  ];
}"
    | save $shell

    $shell
  } else if ($shells | length) > 1 {
    $shells
    | to text
    | fzf
  } else {
    $shells
    | first
  }

  let existing_file = (open $shell)
  ^$env.EDITOR $shell
  let new_file = (open $shell)

  if $new_file != $existing_file {
    environment-activate
  }
}

def get-environments-file-with-features [] {
  let configuration_file = (open-configuration-file)

  $configuration_file
  | get environments
  | each {
    if features in ($in | columns) {
      $in
    } else {
      $in
      | insert features null
    }
  }
}

export def main [] {
  let existing_file = (get-environments-file-with-features)
  ^$env.EDITOR .environments/environments.toml
  let new_file = (get-environments-file-with-features)

  if $new_file.name != $existing_file.name or (
    $new_file.features != $existing_file.features
  ) {
    environment-activate
  }
}
