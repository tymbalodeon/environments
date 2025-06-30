def main [...environments: string] {
  let remote_url = (
    "https://raw.githubusercontent.com/tymbalodeon/environments/trunk"
  )

  git init
  let project_root = (git rev-parse --show-toplevel)

  http get $"($remote_url)/src/generic/flake.nix"
  | save --force $"($project_root)/flake.nix"

  git add .

  let temporary_directory = (mktemp --directory --tmpdir)

  (
    git clone
      https://github.com/tymbalodeon/environments.git
      $temporary_directory
  )

  $env.ENVIRONMENTS = $"($temporary_directory)/src"
  environment add ...$environments
  rm --force --recursive $temporary_directory
}
