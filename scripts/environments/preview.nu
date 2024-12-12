#!/usr/bin/env nu

use ../environment.nu get-project-path
use ../../init/init.nu "main init"

def main [environment?: string] {
  let env_file_path = (get-project-path .env)

  let env_file = if ($env_file_path | path exists) {
    open $env_file_path
  } else {
    null
  }

  let layout_file = (
    open (get-project-path scripts/environments/preview-layout.kdl)
  )

  let directory = (mktemp --directory)

  cd $directory
  git init

  if ($env_file | is-not-empty) {
    $env_file
    | save .env
  }

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
