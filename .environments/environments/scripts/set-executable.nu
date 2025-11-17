#!/usr/bin/env nu

def main [] {
  for file in (
    rg --files-with-matches "/usr/bin/env nu"
    | lines
  ) {
    chmod +x $file
  }
}
