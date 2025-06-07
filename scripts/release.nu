#!/usr/bin/env nu

# TODO: move this to its own module? Since not every generic project has
# "releases"

# Create a new release
def main [] {
  if ("CHANGELOG.md" | path exists) {
    open CHANGELOG.md
    | str replace --all "\n---\n" "\n- - -\n"
    | save --force CHANGELOG.md
  }

  cog bump --auto
}
