#!/usr/bin/env nu

use ../../default/scripts/environment.nu "main update"
use files.nu get-files
use files.nu get-lilypond-version

def "main lilypond" [] {
  main update nixpkgs
}

def "main scores" [] {
  for score in ((get-files "ly") ++ (get-files "ily")) {
    try {
      convert-ly --edit $score

      (
        sd
          '\\version"\d\.\d{2}\.\d{2}"'
          $"\\version \"(get-lilypond-version)\""
          $score
      )
    }
  }
}

# Update dependencies and score LilyPond version
def main [] {
  main lilypond
  main scores
}
