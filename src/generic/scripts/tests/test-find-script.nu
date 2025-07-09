use std assert

use ../../../generic/scripts/find-script.nu get-script

let scripts = [
  scripts/annotate.nu
  scripts/check.nu
  scripts/dependencies.nu
  scripts/diff-env.nu
  scripts/domain.nu
  scripts/environment.nu
  scripts/environments/
  scripts/environments/build.nu
  scripts/environments/help.nu
  scripts/environments/justfile.nu
  scripts/environments/pre-commit-update.nu
  scripts/find-recipe.nu
  scripts/find-script.nu
  scripts/help.nu
  scripts/history.nu
  scripts/init.nu
  scripts/issue.nu
  scripts/pre-commit-update.nu
  scripts/python/add.nu
  scripts/python/build.nu
  scripts/python/clean.nu
  scripts/python/command.nu
  scripts/python/coverage.nu
  scripts/python/deps.nu
  scripts/python/help.nu
  scripts/python/install.nu
  scripts/python/profile.nu
  scripts/python/release.nu
  scripts/python/remove.nu
  scripts/python/run.nu
  scripts/python/shell.nu
  scripts/python/test.nu
  scripts/python/update.nu
  scripts/python/version.nu
  scripts/release.nu
  scripts/remote.nu
  scripts/stats.nu
  scripts/test.nu
  scripts/update.nu
  scripts/update.nu
  scripts/view-source.nu
]

#[test]
def test-get-script-help [] {
  assert equal (get-script help $scripts scripts) scripts/help.nu
}

#[test]
def test-get-script-environments-help [] {
  assert equal (
    get-script environments/help $scripts scripts
  ) scripts/environments/help.nu
}

#[test]
def test-get-script-environments-help-colons [] {
  assert equal (
    get-script environments::help $scripts scripts
  ) scripts/environments/help.nu
}

#[test]
def test-get-script-python [] {
  (
    assert equal
      (get-script python/help $scripts scripts)
      scripts/python/help.nu
  )
}

#[test]
def test-get-script-python-colons [] {
  (
    assert equal
      (get-script python::help $scripts scripts)
      scripts/python/help.nu
  )
}
