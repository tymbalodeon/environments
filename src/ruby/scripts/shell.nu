#!/usr/bin/env nu

use ../../default/scripts/cd-to-root.nu

# Open an interactive ruby shell
def main [] {
  cd-to-root ruby
  irb
}
