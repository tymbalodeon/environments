#!/usr/bin/env nu

# TODO: move this to its own module? Since not every generic project has
# "releases"

# Create a new release
def main [
  --preview # Preview changes without altering anything 
] {
  if (git status --porcelain=1 | lines | length) > 0 {
    let message = (
      [
        "The working copy contains changes."
         "Please commit all changes and try again."
      ]
      | str join " "
    )

    print $message
    exit 1
  }

  if ("CHANGELOG.md" | path exists) {
    open CHANGELOG.md
    | str replace --all "\n---\n" "\n- - -\n"
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
  jj new; jj bookmark set trunk --to @-; jj git push
}
