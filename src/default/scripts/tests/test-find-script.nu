use std assert

use ../../../default/scripts/find-script.nu get-script

let scripts = [
  .environments/default/scripts/check.nu
  .environments/default/scripts/domain.nu
  .environments/default/scripts/environment.nu
  .environments/default/scripts/find-recipe.nu
  .environments/default/scripts/find-script.nu
  .environments/default/scripts/help.nu
  .environments/default/scripts/history.nu
  .environments/default/scripts/issue.nu
  .environments/default/scripts/remote.nu
  .environments/default/scripts/replace.nu
  .environments/default/scripts/stats.nu
  .environments/default/scripts/theme.nu
  .environments/default/scripts/todo.nu
  .environments/default/scripts/source.nu
  .environments/environments/scripts/help.nu
  .environments/environments/scripts/readme.nu
  .environments/environments/scripts/reload.nu
  .environments/environments/scripts/set-executable.nu
  .environments/environments/scripts/sort-gitignores.nu
  .environments/environments/scripts/update.nu
  .environments/git/scripts/release.nu
  .environments/nix/scripts/help.nu
  .environments/nix/scripts/shell.nu
  .environments/python/scripts/add.nu
  .environments/python/scripts/cd-to-root.nu
  .environments/python/scripts/command.nu
  .environments/python/scripts/dependencies.nu
  .environments/python/scripts/help.nu
  .environments/python/scripts/pin.nu
  .environments/python/scripts/profile.nu
  .environments/python/scripts/remove.nu
  .environments/python/scripts/run.nu
  .environments/python/scripts/shell.nu
  .environments/python/scripts/test.nu
  .environments/python/scripts/update.nu
  .environments/python/scripts/version.nu
]

# FIXME: no choose-recipe in tests

#[test]
def test-get-script-help [] {
  assert equal (
    get-script $scripts help
    ) .environments/default/scripts/help.nu
}

#[test]
def test-get-script-environments-help [] {
  assert equal (
    get-script $scripts environments help
  ) .environments/environments/scripts/help.nu
}

#[test]
def test-get-script-environments-help-colons [] {
  assert equal (
    get-script $scripts environments::help
  ) .environments/environments/scripts/help.nu
}

#[test]
def test-get-script-python [] {
  (
    assert equal
      (get-script $scripts python/help)
      .environments/python/scripts/help.nu
  )
}

#[test]
def test-get-script-python-colons [] {
  (
    assert equal
      (get-script $scripts python::help)
      .environments/python/scripts/help.nu

  )
}
