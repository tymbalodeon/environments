#!/usr/bin/env nu

use ../../default/scripts/cd-to-root.nu

# Run tests
def main [] {
  cd-to-root

  uv run pytest tests
}
