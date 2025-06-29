def main [...environments: string] {
  let remote_url = (
    "https://raw.githubusercontent.com/tymbalodeon/environments/trunk"
  )

  git init
  let project_root = (git rev-parse --show-toplevel)

  http get $"($remote_url)/src/generic/flake.nix"
  | save --force $"($project_root)/flake.nix"

  git add .
  environment activate
  environment add ...$environments
}
