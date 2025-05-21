#!/usr/bin/env nu

use ../domain.nu parse-git-origin
use ../environment.nu get-project-path

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
  $"($start)\(.|\\s\)*($end)"
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

# Update repo link in README
def main [] {
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
