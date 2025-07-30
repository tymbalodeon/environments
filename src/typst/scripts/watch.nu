#!/usr/bin/env nu

def main [file?: string] {
  let file = if ($file | is-empty) {
    "main.typ"
  } else {
    $file
  }

  let layout_file = (mktemp --tmpdir $"($file)-XXX.kdl")

  cat $"($env.ENVIRONMENTS)/typst/layout.kdl"
  | str replace --all "[file]" $file
  | save --force $layout_file

  start ($file | path parse | update extension pdf | path join)
  zellij --layout $layout_file attach --create $file
  rm --force $layout_file
  zellij delete-session $file
}
