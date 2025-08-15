#!/usr/bin/env nu

def get-revision-names [type: string] {
  jj $type list --template "name ++ '\n'"
  | lines
  | uniq
}

def get-bookmarks [] {
  get-revision-names bookmark
  | append (get-revision-names tag)
}

def main [
  bookmark?: string # The name of the bookmark to create or edit
  --from-current # Create a new bookmark off of the current revision instead of trunk
  --revision: string # Switch to this particular revision
] {
  if ($bookmark in (get-bookmarks)) {
    let revision = if ($revision | is-not-empty) {
      $revision
    } else {
      let revisions = (
        jj log
          --no-graph
          --revisions $"descendants\(($bookmark)\)"
          --template "change_id ++ '•' ++ description ++ '\n'"
        | lines
        | where {is-not-empty}
        | each {
            |line|

            let parts = ($line | split row •)

            {
              change_id: $parts.0
              description: $parts.1
            }
          }
      )

      if ($revisions | length) == 1 {
        $revisions
        | first
        | get change_id
      } else {
        $revisions
        | each {|revision| $"($revision.change_id) ($revision.description)"}
        | to text
        | fzf
        | split row " "
        | first
      }
    }

    if (
      jj log --no-graph --revisions $revision --template "immutable"
      | into bool
    ) {
      jj new --revisions $revision
    } else {
      jj edit --revisions $revision
    }
  } else {
    let revision = if $from_current {
      "@"
    } else if ($revision | is-not-empty) {
      $revision
    } else {
      "trunk"
    }

    let prompt = (
      [
        "Are you sure you want to create a new bookmark "
        $bookmark
        " starting from "
        $revision
        "? [y/N] "
      ]
      | str join
    )

    let confirmed = (input --numchar 1 $prompt)

    if ($confirmed | str downcase) in [yes y] {
      jj new $revision
      jj bookmark create $bookmark --revision @
    }
  }
}
