#!/usr/bin/env nu

use ../environment.nu merge_gitignores
use ../environment.nu merge_justfiles
use ../environment.nu merge_pre_commit_configs
use ../environment.nu save_pre_commit_config
use ../filesystem.nu get-project-path
use pre-commit-update.nu

def get-environment-files [] {
  let generic_directory = (get-project-path src/generic)

  fd --hidden --ignore --exclude .git "" $generic_directory
  | lines
  | filter {
      |file|

      let path = ($file | path parse)

      (
        ($file | path type) == "file"
        and "tests" not-in $path.parent
        and $path.extension != "lock"
      )
    }
}

def get_build_path [path: string] {
  $path
  | str replace --regex "src/[a-zA-Z-_]+/" ""
}

def get-environment-directories [environment_files: list<string>] {
  $environment_files
  | path parse
  | get parent
  | uniq
  | str replace "src/generic" ""
  | filter {|directory| $directory | is-not-empty}
  | str replace "/" ""

}

def copy-file [source_file: string file: string] {
  cp $source_file $file

  print $"Updated ($file)"

}

def copy-files [environment_files: list<string>] {
  for directory in (get-environment-directories $environment_files) {
    mkdir $directory
  }

  let environment_files = (
    $environment_files
    | filter {
        |file|

        ($file | path basename) not-in [
          .gitignore
          .pre-commit-config.yaml
          Justfile
        ] and ($file | path parse | get extension) != "just"
      }
  )

  for source_file in $environment_files {
    let file = (get_build_path $source_file)

    copy-file $source_file $file
  }
}

def copy-justfile [] {
  (
    merge_justfiles
      generic
      Justfile
      src/generic/Justfile
  ) | save --force Justfile

  print $"Updated Justfile"
}

def copy-gitignore [] {
  (
    merge_gitignores
      (open .gitignore)
      generic
      (open src/generic/.gitignore)
  ) | save --force .gitignore

  print $"Updated .gitignore"
}

def copy-pre-commit-config [] {
  save_pre_commit_config (
    merge_pre_commit_configs
      (open --raw .pre-commit-config.yaml)
      generic
      (open --raw src/generic/.pre-commit-config.yaml)
  )
}

def force-copy-files [] {
  copy-files (get-environment-files)
  copy-gitignore
  copy-pre-commit-config
  copy-justfile
}

def get-modified [file: string] {
  try {
    ls $file
    | first
    | get modified
  }
}

def get-files-and-modified [] {
  get-environment-files
  | wrap environment
  | insert local {
      |$file|

      $file.environment | str replace "src/generic/" ""
    }
  | insert environment_modified {
      |row|

      get-modified $row.environment
    }
  | insert local_modified {
      |row|

      get-modified $row.local
  }
}

export def get-outdated-files [files: list] {
  $files
  | filter {
      |file|

      ($file.local_modified == null) or (
        $file.environment_modified > $file.local_modified
      )
    }
  | get environment
}

def copy-outdated-files [] {
  let outdated_files = (get-outdated-files (get-files-and-modified))

  mut environment_files = []

  for source_file in $outdated_files {
    let basename = ($source_file | path basename)

    if $basename == ".gitignore" {
      copy_gitignore
    } else if $basename == ".pre-commit-config.yaml" {
      copy_pre_commit_config
    } else if $basename == "Justfile" {
      copy_justfile
    } else {
      let file = (
        $source_file
        | str replace "src/generic/" ""
      )

      copy-file $source_file $file
    }
  }
}

# Build dev environment
def main [
  --force # Build environment even if up-to-date
  --update # Update all pre-commit-conifg files
] {
  if $force {
    force-copy-files
  } else {
    copy-outdated-files
  }

  if $force or $update {
    pre-commit-update
  }
}
