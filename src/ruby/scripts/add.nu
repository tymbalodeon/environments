#!/usr/bin/env nu

use ../../default/scripts/cd-to-root.nu

def main [
  ...dependencies: string, # Dependencies to add
  --dev # Add dependencies to the development group
] {
  cd-to-root ruby

  if $dev {
    bundle add --group dev ...$dependencies
  } else {
    bundle add --group prod ...$dependencies
  }
}
