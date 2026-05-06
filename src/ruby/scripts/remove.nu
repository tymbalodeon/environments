#!/usr/bin/env nu

use ../../default/scripts/cd-to-root.nu

# Remove dependencies
def main [
  ...dependencies: string # Dependencies to remove
] {
  cd-to-root ruby
  bundle remove ...$dependencies
}
