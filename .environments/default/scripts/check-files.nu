#!/usr/bin/env nu

use environment.nu print-error

# Check that files are valid
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

  let tracked_files = (jj file list | lines)

  mut files = []

  for file in (
    $extensions 
    | each {fd --extension $in --hidden | lines}
    | flatten
    | where {$in in $tracked_files}
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
