#!/usr/bin/env nu

# TODO: move this to its own module? Since not every generic project has
# "releases"

# Create a new release
def main [] {
  cog bump --auto
}
