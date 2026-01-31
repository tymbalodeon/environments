#!/usr/bin/env nu

use print.nu print-error
use print.nu print-warning

def get-revision-names [type: string] {
  jj $type list --template "name ++ '\n'"
  | lines
  | uniq
}

def get-bookmarks [] {
  get-revision-names bookmark
  | append (get-revision-names tag)
}

# Switch to a development revision
def main [
  name?: string # The name of the bookmark to switch to
  --choose # Choose the revision to switch to interactively
  --revision: string # Switch to this particular revision
] {
  let bookmarks = (get-bookmarks)

  let name = if ($name | is-not-empty) {
    $name
  } else {
    $bookmarks
    | to text
    | fzf
  }

  if ($name | is-empty) {
    return
  }

  if ($name not-in $bookmarks) {
    print-error $"unrecognized bookmark `($name)`"

    return
  }

  let revision = if ($revision | is-not-empty) {
    $revision
  } else {
    let revisions = (
      jj log
        --no-graph
        --revisions $"descendants\(($name)\)"
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

    if $choose {
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
    } else {
      $revisions
      | first
      | get change_id
    }
  }

  if ($revision | is-empty) {
    return
  }

  if (
    jj log --no-graph --revisions $revision --template "immutable"
    | into bool
  ) {
    jj new $revision
  } else {
    jj edit $revision
  }
}

# List development bookmarks
def "main list" [] {
  jj bookmark list
}

# List development bookmarks
def "main list names" [] {
  jj bookmark list --template "name ++ '\n'"
}

# Create a new development bookmark
def "main new" [
  name?: string # The name of the bookmark to create
  --from: string # The revision to start from (defaults to the current revision)
  --issue: int # The issue ID of the issue whose name to use
] {
  let name = if ($name | is-empty) {
    let json = if ($issue | is-empty) {
      gh issue list --json title
      | from json
      | get title
      | to text
      | fzf
    } else {
      gh issue view --json title $issue 
      | from json
      | get title
    }
  } else {
    $name
  }

  if ($from | is-not-empty) {
    jj new $from
  }

  if $name not-in (get-bookmarks) {
    jj bookmark create $name
    jj bookmark track $name
    jj describe --message $"chore: init ($name)"
    jj git push
  } else {
    print-warning $"bookmark ($name) already exists"
  }
}

# Sync development bookmarks with trunk
def "main sync" [] {
  print "Implement me!"
}
