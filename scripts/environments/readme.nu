#!/usr/bin/env nu

use ../domain.nu parse-git-origin
use ../project.nu get-project-path

# Update repo link in README
def main [] {
  let origin = (git remote get-url origin | split row "@" | last)

  let output = $"<!-- `init` start -->

```sh
nix run github:tymbalodeon/environments?dir=init# --no-write-lock-file \\
  init [ENVIRONMENT]...
```

<!-- `init` end -->"

  let readme = (get-project-path README.md)

  open $readme
  | (
      str replace
        --regex $"<!-- `init` start -->\(.|\\s\)*<!-- `init` end -->"
        $output
    )
  | save --force $readme
}
