def main [...environments: string] {
  let remote_url = (
    "https://raw.githubusercontent.com/tymbalodeon/environments/trunk"
  )

  git init
  let project_root = (git rev-parse --show-toplevel)

  http get $"($remote_url)/src/generic/flake.nix"
  | save --force $"($project_root)/flake.nix"

  git add .

  # FIXME: this doesn't work because activate runs in the background and line 16
  # runs without knowing whether or not the activation is complete
  environment activate
  environment add ...$environments
}
