#!/usr/bin/env nu

def main [] {
  zellij --layout $env.ENVIRONMENTS_RUST_ZELLIJ_LAYOUT
}
