#!/usr/bin/env nu

def "main remove" [] {
  open pyproject.toml
  | reject build-system
  | save --force pyproject.toml

  taplo format pyproject.toml
}

def main [] {
  open pyproject.toml
  | update build-system {
      requires: ["hatchling"]
      build-backend: "hatchling.build"
    }
  | save --force pyproject.toml

  taplo format pyproject.toml
}
