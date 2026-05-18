#!/usr/bin/env nu

# Check project
def main [] {
  cargo check --color always
}
