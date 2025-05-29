def main [...environments: string] {
  let base_url = (
    "https://raw.githubusercontent.com/tymbalodeon/environments/trunk"
  )

  let flake_file = $"(git rev-parse --show-toplevel)/flake.nix"

  if not ($flake_file | path exists) {
    http get $"($base_url)/src/generic/flake.nix"
    | save $"(git rev-parse --show-toplevel)/flake.nix"
  }

  let environments_file = $"(git rev-parse --show-toplevel)/.environments.toml"

  if not ($environments_file | path exists) {
    http get $"($base_url)/src/generic/.environments.toml"
    | save $"(git rev-parse --show-toplevel)/.environments.toml"
  }

  environment add ...$environments
}
