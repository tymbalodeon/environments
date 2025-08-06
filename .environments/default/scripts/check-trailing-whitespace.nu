#!/usr/bin/env nu

# Remove trailing whitespace from lines
def main [] {
  for file in (
    jj file list
    | lines
    | where {
        open --raw $in
        | lines
        | where {($in | str ends-with " ") and ($in != "\n")}
        | is-not-empty
      }
  ) {
    open --raw $file
    | lines
    | each {$in | str trim --right}
    | to text
    | collect
    | save --force $file
  }
}
