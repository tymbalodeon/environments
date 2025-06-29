#!/usr/bin/env nu

def main [file: string] {
  let layout_file = (mktemp --tmpdir $"($file)-XXX.kdl")

  cat typst-layout.kdl
  | str replace --all "[file]" $file
  | save --force $layout_file

  start $file
  zellij --layout $layout_file attach --create $file
  rm --force $layout_file
  zellij delete-session $file
}
