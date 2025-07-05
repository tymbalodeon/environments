#!/usr/bin/env nu

use ../../../generic/scripts/domain.nu parse-git-origin

def "main remove" [] {
  rm --force cog.toml
}

def get-signature [username: string domain: string] {
  let signature = if $domain == github {
    gh repo view --json assignableUsers
    | from json
    | get assignableUsers
    | where login == $username
  } else if $domain == gitlab {
    glab repo contributors
    | lines
    | drop nth 0
    | where {is-not-empty}
    | each {$in | split row "\t" | first}
    | uniq
    | first
  }

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

  let repo_info = (parse-git-origin (git remote get-url origin))

  open cog.toml
  | upsert ignore_merge_commits true
  | upsert tag_prefix ""
  | upsert changelog.authors [
      {
        signature: (get-signature ($repo_info.owner) $repo_info.domain)
        username: $repo_info.owner
      }
    ]
  | upsert changelog.owner $repo_info.owner
  | upsert changelog.remote $repo_info.domain
  | upsert changelog.repository $repo_info.repo
  | upsert changelog.template remote
  | save --force cog.toml
}
