#!/usr/bin/env nu

def main [] {
  # FIXME
  cp src/default/flake.nix .
  rm --force flake.lock
  just environment activate
}
