#!/usr/bin/env nu

use ../project.nu get-project-root

def main [] {
  cargo install --path (get-project-root)
}
