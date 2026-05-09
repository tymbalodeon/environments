#!/usr/bin/env nu

# Clean all generated files
def main [] {
  rm --force --recursive result
}
