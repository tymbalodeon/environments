#!/usr/bin/env nu

use open-documentation.nu

# Open a pre-configured development environment
def main [] {
  open-documentation
  zellij --layout $env.ENVIRONMENTS_DOCUMENTATION_ZELLIJ_LAYOUT
}
