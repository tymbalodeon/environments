#!/usr/bin/env nu

# TODO: move this to its own module? Since not every generic project has
# "releases"

use ./check.nu

# Create a new release
def main [
  --preview # Preview new additions to the CHANGELOG without modifyiing anything
] {
  if not $preview {
    if not ((git branch --show-current) == "trunk") {
      print "Can only release from the trunk branch."
      exit 1
    }

    if (git status --short | is-not-empty) {
      print "Please commit all changes before releasing."
      exit 1
    }

    check
  }

  cog bump --auto
}
