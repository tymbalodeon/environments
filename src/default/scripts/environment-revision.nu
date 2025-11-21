def get-current-revision [] {
  try {
    open flake.nix
    | find github:tymbalodeon/environments/
    | first
    | ansi strip
    | str trim
    | parse 'url = "github:tymbalodeon/environments/{revision}?dir=src";'
    | first
    | get revision
    | str trim
  } catch {
    ""
  }
}

export def "revision get" [] {
  let current_revision = (get-current-revision)

  if ($current_revision | is-empty) {
    return
  } else {
    $current_revision
  }
}

export def "revision set" [revision: string] {
  # gh api repos/tymbalodeon/environments/tags

  try {
    (
      gh search commits
        --hash $revision
        --json commit
        --owner tymbalodeon
        --repo environments
        err> /dev/null
      | from json
      | get commit.tree.sha
    )
  } catch {
    print-error $"invalid revision: \"($revision)\""

    return
  }

  let repo_url_base = "github:tymbalodeon/environments"

  open flake.nix
  | (
      str replace
        $"($repo_url_base)/(get-current-revision)"
        $"($repo_url_base)/($revision)"
    )
  | save --force flake.nix
}
