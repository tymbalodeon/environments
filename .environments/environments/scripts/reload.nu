#!/usr/bin/env nu

def main [] {
  cp src/default/flake.nix .
  rm --force flake.lock
  just environment activate
}
