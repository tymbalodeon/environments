#!/usr/bin/env nu

use domain.nu

# View remote repository
def main [
  --web # Open the remote repository website in the browser
] {
  let domain = try {
    domain err> /dev/null
  } catch {
    return
  }

  match (domain) {
    "github" => {
      if $web {
        gh repo view --web
      } else {
        gh repo view
      }
    }

    "gitlab" => {
      if $web {
        glab repo view --web
      } else {
        glab repo view
      }
    }
  }
}
