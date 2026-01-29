#!/usr/bin/env nu

use print.nu print-error

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
  --latest # Switch to the most recent revision
  --revision: string # Switch to this particular revision
] {
  let bookmark = if ($bookmark | is-not-empty) {
    $bookmark
  } else {
    get-bookmarks
    | to text
    | fzf
  }

  if ($bookmark | is-empty) {
    return
  }

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
      } else if $latest {
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
  } else {
    print-error $"unrecognized bookmark `($bookmark)`"
  }
}

def "main new" [
  title?: string # The name of the issue/branch to create
  --edit # Edit the new issue before developing
  --from-current # Create a new bookmark off of the current revision instead of main
  --revision: string # Create a new bookmark off of a particular revision
] {
  let revision = if $from_current {
    "@"
  } else if ($revision | is-not-empty) {
    $revision
  } else {
    let bookmarks = (get-bookmarks)

    if main in $bookmarks {
      "main"
    } else if master in $bookmarks {
      "master"
    } else if trunk in $bookmarks {
      "trunk"
    } else {
      print-error "could not determine the default bookmark"
      print-error "please specify the bookmark name to start from"
    }
  }

  let title = if ($title | is-empty) {
    gh issue create --editor 

    gh issue list --json title
    | from json
    | first
    | get title
  } else {
    if $edit {
      gh issue create --editor --title $title
    } else {
      gh issue create --body "" --title $title
    }

    $title
  }

  if not $from_current {
    jj new $revision
  }

  jj bookmark create $title --revision $revision
  jj bookmark track $title --remote origin
  jj describe --message $"chore: init ($title)"
}

# get number from gh pr view $branch --json number,status
# check for status == OPEN, then
# gh pr merge $number --auto --squash

