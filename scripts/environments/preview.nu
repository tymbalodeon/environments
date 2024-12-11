#!/usr/bin/env nu

use ../environment.nu get-project-path
use ../../init/init.nu "main init"

def main [environment?: string] {
  let env_file = (open (get-project-path .env))

  let layout_file = (
    open (get-project-path scripts/environments/preview-layout.kdl)
  )

  let directory = (mktemp --directory)

  cd $directory

  $env_file
  | save .env

  let environments = if ($environment | is-empty) {
    []
  } else {
    [$environment]
  }

  main init ...$environments

  $layout_file
  | str replace "[directory]" $directory
  | save preview-layout.kdl
 
  zellij --layout preview-layout.kdl

  rm --force --recursive $directory
}
