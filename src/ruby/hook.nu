#!/usr/bin/env nu

use ../.scripts/environments-file.nu get-root

def "main remove" [] {
  rm --force Gemfile
}

def main [] {
  let root = (get-root ruby)

  if ($root | is-not-empty) {
    main remove
    cd $root
  }

  try { bundle init err> /dev/null }
}
