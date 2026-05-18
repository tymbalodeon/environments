#!/usr/bin/env nu

# Add dependencies
def --wrapped main [...args: string] {
  cargo add ...$args
}
