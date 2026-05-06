#!/usr/bin/env nu

use open-documentation.nu

# Open a pre-configured development environment
def main [] {
  open-documentation

  # FIXME: figure out how to pass this via the documentation/devenv.nix file
  # auto-discovering a `layout.kdl` file
  zellij --layout $"($env.ENVIRONMENTS)/documentation/layout.kdl"
}
