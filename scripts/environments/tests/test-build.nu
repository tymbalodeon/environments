use std assert

use ../build.nu get-outdated-files

let environment_files = [
  src/generic/.gitignore
  src/generic/.pre-commit-config.yaml
  src/generic/Justfile
  src/generic/cog.toml
  src/generic/flake.nix
  src/generic/pyproject.toml
  src/generic/scripts/annotate.nu
  src/generic/scripts/check.nu
  src/generic/scripts/deps.nu
  src/generic/scripts/diff-env.nu
  src/generic/scripts/domain.nu
  src/generic/scripts/find-recipe.nu
  src/generic/scripts/help.nu
  src/generic/scripts/history.nu
  src/generic/scripts/init.nu
  src/generic/scripts/issue.nu
  src/generic/scripts/release.nu
  src/generic/scripts/remote.nu
  src/generic/scripts/stats.nu
  src/generic/scripts/update.nu
  src/generic/scripts/view-source.nu
]

let local_files = [
  .gitignore
  .pre-commit-config.yaml
  Justfile
  cog.toml
  flake.nix
  pyproject.toml
  scripts/annotate.nu
  scripts/check.nu
  scripts/deps.nu
  scripts/diff-env.nu
  scripts/domain.nu
  scripts/find-recipe.nu
  scripts/help.nu
  scripts/history.nu
  scripts/init.nu
  scripts/issue.nu
  scripts/release.nu
  scripts/remote.nu
  scripts/stats.nu
  scripts/update.nu
  scripts/view-source.nu
]

let files = (
  $environment_files | wrap environment
  | merge ($local_files | wrap local)
)

let old = "2024-09-20"
let new = "2024-09-21"

#[test]
def test-get-outdated-files-no-changes [] {
  let files = (
    $files
    | insert environment_modified $old
    | insert local_modified $old
  )

  let actual_outdated_files = (get-outdated-files $files)
  let expected_outdated_files = []

  assert equal $actual_outdated_files $expected_outdated_files
}

#[test]
def test-get-outdated-files-local-newer [] {
  let files = (
    $files
    | insert environment_modified $old
    | insert local_modified $new
  )

  let actual_outdated_files = (get-outdated-files $files)
  let expected_outdated_files = []

  assert equal $actual_outdated_files $expected_outdated_files
}

#[test]
def test-get-outdated-files-environment-newer [] {
  let files = (
    $files
    | insert environment_modified $new
    | insert local_modified $old
  )

  let actual_outdated_files = (get-outdated-files $files)
  let expected_outdated_files = $files.environment

  assert equal $actual_outdated_files $expected_outdated_files
}

#[test]
def test-get-outdated-files-new-file [] {
  let new_file = "src/generic/scripts/new-file.nu"

  let files = (
    $environment_files
    | append $new_file
    | wrap environment
    | merge ($local_files | wrap local)
  )

  let test = {
    files: (
      $files
      | insert environment_modified $old
      | insert local_modified $old
      | update environment_modified {
          |row|

          if $row.environment == $new_file {
            $new
          } else {
            $old
          }
        }
      | update local_modified {
          |row|

          if $row.environment == $new_file {
            null
          } else {
            $old
          }
        }
    )

    expected_outdated_files: [$new_file]
  }

  let actual_outdated_files = (get-outdated-files $test.files)

  assert equal $actual_outdated_files $test.expected_outdated_files
}
