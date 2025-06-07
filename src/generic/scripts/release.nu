#!/usr/bin/env nu

# TODO: move this to its own module? Since not every generic project has
# "releases"

# Create a new release
def main [
  --preview # Preview changes without altering anything 
] {
  # TODO check if there are working copy changes and if so exit
  
  if ("CHANGELOG.md" | path exists) {
    open CHANGELOG.md
    | str replace --all "\n---\n" "\n- - -n"
    | save --force CHANGELOG.md

    jj describe --message "chore: prepare CHANGELOG.md for release"
    jj new
  }

  if $preview {
    cog bump --auto --dry-run
  } else {
    cog bump --auto
  }

  prettier CHANGELOG.md
  jj describe --message "chore: format CHANGELOG.md after release"
  jj bookmark set trunk; jj git push; jj new
}
