#!/usr/bin/env nu

use environment.nu print-error

def main [] {
  let extensions = [
    csv
    eml
    ics
    ini
    json
    msgpack
    msgpackz
    nuon
    ods
    plist
    ssv
    toml
    tsv
    url
    vcf
    xlsx
    xml
    yaml
    yml
  ]

  mut files = []

  for file in (
    $extensions 
    | each {fd --extension $in --hidden | lines}
    | flatten
  ) {
    let file = (
      try {
        open $file
        null
      } catch {
        $file
      }
    )

    if ($file | is-not-empty) {
      $files = ($files | append $file)
    }
  }

  for $file in $files {
    print-error $file
  }

  if ($files | is-not-empty) {
    exit 1
  }
}
