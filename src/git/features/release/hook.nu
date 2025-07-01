#!/usr/bin/env nu

def "main remove" [] {
  rm --force cog.toml
}

def get-signature [username: string] {
  # TODO: handle non-github
  let signature = (
    gh repo view --json assignableUsers
    | from json
    | get assignableUsers
    | where login == $username
  )

  if ($signature | is-not-empty) {
    $signature.name
    | first
  } else {
    $username
  }
}

def main [] {
  if (cog init | complete | get exit_code) != 0 {
    return
  }

  # TODO: can this be pulled from another file (domain.nu)?
  # TODO: handle non-github
  let repo_info = (
    git remote get-url origin
    | parse "git@{remote}:{owner}/{repository}.git"
    | first
  )

  open cog.toml
  | upsert ignore_merge_commits true
  | upsert tag_prefix ""
  | upsert changelog.authors [
      {
        signature: (get-signature ($repo_info.owner))
        username: $repo_info.owner
      }
    ]
  | upsert changelog.owner $repo_info.owner
  | upsert changelog.remote $repo_info.remote
  | upsert changelog.repository $repo_info.repository
  | upsert changelog.template remote
  | save --force cog.toml
}
