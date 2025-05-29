def main [...environments: string] {
  let base_url = (
    "https://raw.githubusercontent.com/tymbalodeon/environments/trunk"
  )

  git init
  let project_root = (git rev-parse --show-toplevel)

  http get $"($base_url)/src/generic/flake.nix"
  | save --force $"($project_root)/flake.nix"

  let environments_file = $"($project_root)/.environments.toml"

  if not ($environments_file | path exists) {
    http get $"($base_url)/src/generic/.environments.toml"
    | save $environments_file
  }

  git add .
  environment add ...$environments
}
