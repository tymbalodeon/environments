#!/usr/bin/env nu

use ../../default/scripts/cd-to-root.nu

# Update dependencies
def main [
  # TODO: implement me!
  --breaking # Update to latest SemVer-breaking versions
  --dev # Update only development dependencies
  --prod # Update only production dependencies
] {
  # TODO: allow passing the names of dependencies?
  cd-to-root ruby

  if $breaking {
    # TODO: implement me!
  } else {
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
}
