#!/usr/bin/env nu

export def --env main [] {
  if (".environments.toml" | path exists) {
    let python = (
      open .environments.toml
      | get environments
      | where name == python
    )

    if root in ($python | columns ) {
      cd (
        $python
        | get root
        | first
      )
    }
  }
}
