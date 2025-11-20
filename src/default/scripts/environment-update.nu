use environment-activate.nu 

export def main [
  inputs: list<string>
] {
  let update_environments = [environments env] | any {$in in $inputs}

  if ($inputs | is-empty) or $update_environments {
    let remote_url = (
      "https://raw.githubusercontent.com/tymbalodeon/environments/trunk"
    )

    let project_root = (git rev-parse --show-toplevel)

    http get $"($remote_url)/src/default/flake.nix"
    | save --force $"($project_root)/flake.nix"
  }

  if ($inputs | is-empty) {
    nix flake update
  } else {
    nix flake update ...$inputs
  }

  environment-activate
}
