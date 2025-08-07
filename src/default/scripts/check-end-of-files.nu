#!/usr/bin/env nu
# https://github.com/pre-commit/pre-commit-hooks/blob/main/pre_commit_hooks/end_of_file_fixer.py

# Fix end of files
def main [] {
  for file in (jj file list | lines) {
    open --raw $file
    | str trim
    | append "\n"
    | str join
    | to text
    | collect
    | save --force $file
  }
}
