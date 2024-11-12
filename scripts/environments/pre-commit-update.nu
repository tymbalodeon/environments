#!/usr/bin/env nu

use ../filesystem.nu get-project-absolute-path

export def main [] {
  let src_directory = (get-project-absolute-path src)

  for directory in (ls $src_directory | get name) {
    cd $directory

    try {
      uv run pre-commit-update err> /dev/null
    }
  }
}
