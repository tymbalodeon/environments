#!/usr/bin/env nu

def main [] {
  uv init --bare err> /dev/null
  uv add --dev bpython pytest
  taplo format pyproject.toml
}
