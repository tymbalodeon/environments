#!/usr/bin/env nu

use ../../default/scripts/cd-to-root.nu

# Update dependencies
def main [
  ...dependencies: string # Dependencies to update
  --dev # Update only development dependencies
  --prod # Update only production dependencies
] {
  cd-to-root ruby

  let group = if $dev {
    "dev"
  } else if $prod {
    "prod"
  }

  if ($group | is-not-empty) {
    bundle update --group $group
  } else {
    bundle update
  }
}
