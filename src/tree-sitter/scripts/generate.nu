#!/usr/bin/env nu

use ../../default/scripts/cd-to-root.nu

def main [] {
  cd-to-root tree-sitter
  bun run tree-sitter generate --js-runtime bun
}
