#!/usr/bin/env nu

# Show dependencies
def main [] {
  cargo tree --depth 1
}
