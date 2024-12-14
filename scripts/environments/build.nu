#!/usr/bin/env nu

use ../domain.nu parse-git-origin
use ../environment.nu display-message
use ../environment.nu merge-gitignores
use ../environment.nu merge-justfiles
use ../environment.nu merge-pre-commit-configs
use ../environment.nu save-file
use ../environment.nu save-pre-commit-config
use ../environment.nu get-project-path
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

def get-build-path [path: string] {
  $path
  | str replace --regex "src/[a-zA-Z-_]+/" ""
}

def get-environment-directories [environment_files: list<string>] {
  $environment_files
  | path parse
  | get parent
  | uniq
  | str replace "src/generic" ""
  | str replace "//" "/"
  | filter {is-not-empty}
}

def copy-file [source_file: string file: string] {
  cp $source_file $file

  display-message Updated $file
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
    let file = (get-build-path $source_file)

    copy-file $source_file $file
  }
}

def copy-justfile [] {
  save-file (
    merge-justfiles
      generic
      Justfile
      src/generic/Justfile
  ) Justfile
}

def copy-gitignore [] {
  save-file (
    merge-gitignores
      (open  (get-project-path .gitignore))
      generic
      (open (get-project-path src/generic/.gitignore))
  ) .gitignore
}

def copy-pre-commit-config [] {
  save-pre-commit-config (
    merge-pre-commit-configs
      (open --raw (get-project-path .pre-commit-config.yaml))
      generic
      (open --raw (get-project-path src/generic/.pre-commit-config.yaml))
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
  | insert local {$in.environment | str replace "src/generic/" ""}
  | insert environment_modified {get-modified $in.environment}
  | insert local_modified {get-modified $in.local}
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

    match $basename {
      ".gitignore" => (copy-gitignore)
      ".pre-commit-config.yaml" => (copy-pre-commit-config)
      "Justfile" => (copy-justfile)

      _ => {
        let file = (
          $source_file
          | str replace "src/generic/" ""
        )

        copy-file $source_file $file
      }
    }
  }
}

def make-comment [command: string type: string] {
  $"<!-- `($command)` ($type) -->"
}

def get-command-comments [command: string] {
  {
    start: (make-comment $command start)
    end: (make-comment $command end)
  }
}

def get-comment-regex [start: string end: string] {
  return $"($start)\(.|\\s\)*($end)"
}

def get-readme-link [
  origin: string
  command: string
  start: string
  end: string
] {
  let origin = (parse-git-origin $origin)
  let repo_path = $"($origin.domain):($origin.owner)/($origin.repo)"

  $"($start)

```sh
nix run ($repo_path)/init?dir=init# --no-write-lock-file \\
  ($command) PATH [ENVIRONMENT]...
```

($end)"
}

def update-readme [] {
  let origin = (git remote get-url origin)

  for command in [init new] {
    let comments = (get-command-comments $command)
    let regex = (get-comment-regex $comments.start $comments.end)

    let output = (
      get-readme-link $origin $command $comments.start $comments.end
    )

    let readme = (get-project-path README.md)

    open $readme
    | str replace --regex $regex $output
    | save --force $readme
  }
}

# Build dev environment
def main [
  --force # Build environment even if up-to-date
  --update-pre-commit-configs # Update all pre-commit-conifg files
] {
  if $force {
    force-copy-files
  } else {
    copy-outdated-files
  }

  if $force or $update_pre_commit_configs {
    pre-commit-update
  }

  update-readme
}
