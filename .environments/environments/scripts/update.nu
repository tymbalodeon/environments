#!/usr/bin/env nu

# Update init flake
def main [] {
  cd init
  nix flake update
}
