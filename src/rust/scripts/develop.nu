#!/usr/bin/env nu

# Open development environment
def main [] {
  zellij --layout $env.ENVIRONMENTS_RUST_ZELLIJ_LAYOUT
}
