#!/usr/bin/env nu

use ../environment.nu get-project-path

export def main [] {
  let src_directory = (get-project-path src)

  for directory in (ls $src_directory | get name) {
    cd $directory

    try {
      uv run pre-commit-update err> /dev/null
    }
  }
}
