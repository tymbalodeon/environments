#!/usr/bin/env nu

use environment.nu upgrade

# Update dependencies
def main [
  --upgrade-environment
] {
  if $upgrade_environment {
    update
  }

  nix flake update
}
