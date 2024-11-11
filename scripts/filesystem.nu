#!/usr/bin/env nu

def get-project-root [] {
  echo (git rev-parse --show-toplevel)
}

export def get-project-absolute-path [path: string] {
  (get-project-root)
  | path join $path
}
