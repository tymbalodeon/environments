#!/usr/bin/env nu

# Remove dependencies
def main [
  ...dependencies: string # Dependencies to remove
] {
  for dependency in $dependencies {
      cargo remove $dependency
  }
}
