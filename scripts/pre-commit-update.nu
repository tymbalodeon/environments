#!/usr/bin/env nu

export def main [] {
  for directory in (ls src | get name) {
    cd $directory
    uv run pre-commit-update
  }
}
