#!/usr/bin/env nu

# TODO: move this to its own module? Since not every generic project has
# "releases"

# Create a new release
def main [
  --preview # Preview changes without altering anything 
] {
  if $preview {
    cog bump --auto --dry-run
  } else {
    cog bump --auto
  }
}
