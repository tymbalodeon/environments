def main [...environments: string] {
  let base_url = (
    "https://raw.githubusercontent.com/tymbalodeon/environments/trunk"
  )

  http get $"($base_url)/src/generic/flake.nix"
  | save --force $"(git rev-parse --show-toplevel)/flake.nix"

  let environments_file = $"(git rev-parse --show-toplevel)/.environments.toml"

  if not ($environments_file | path exists) {
    http get $"($base_url)/src/generic/.environments.toml"
    | save $environments_file
  }

  environment add ...$environments
}
