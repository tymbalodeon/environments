#!/usr/bin/env nu

def main [] {
  open pyproject.toml
  | update build-system {
      requires: ["hatchling"]
      build-backend: "hatchling.build"
    }
}
