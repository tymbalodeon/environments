#!/usr/bin/env nu

use ../../default/scripts/cd-to-root.nu

# Show application dependencies
def main [
  --dev # Show only development dependencies
  --prod # Show only production dependencies
] {
  cd-to-root ruby

  if $dev {
    bundle list --only-group dev
  } else if $prod {
    bundle list --only-group prod
  } else {
    bundle list
  }
}
