#!/usr/bin/env nu

# Format rust code
def main [] {
  # TODO: handle dx (see languages.toml), possibly as a feature
  cargo fmt
}
