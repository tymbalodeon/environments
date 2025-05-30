#!/usr/bin/env nu

def main [] {
  rm --force flake.lock
  just environment activate
  jj restore flake.lock
}
