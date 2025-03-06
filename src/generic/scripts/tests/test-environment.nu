use std assert

use ../environment.nu find-environment-file-url
use ../environment.nu merge-gitignores
use ../environment.nu merge-justfiles
use ../environment.nu merge-pre-commit-configs
use ../environment.nu remove-environment-from-gitignore
use ../environment.nu remove-environment-from-justfile
use ../environment.nu remove-environment-from-pre-commit-config

#[before-all]
def get-mock-files [] {
  {
    mocks: (fd --hidden "" (fd mocks) | lines)
  }
}

def get-mock-file [mocks: list<string> filename: string] {
  $mocks
  | filter {
      |file|

      ($file | path basename) == $filename
    }
  | first
}

#[test]
def test-find-environment-file-url [] {
  let environment_files = (
    open (get-mock-file $in.mocks environment-files.nuon)
  )

  let actual_url = (
    find-environment-file-url
      python
      .gitignore
      $environment_files
  )

  let expected_url = "https://raw.githubusercontent.com/tymbalodeon/environments/trunk/src/python/.gitignore"

  assert equal $actual_url $expected_url
}

#[test]
def test-merge-gitignores [] {
  let generic_gitignore = ".config
.direnv
.envrc
.pdm-python
.venv"

  let environment_gitignore = "*.pyc
.coverage
__pycache__/
build/
dist/"

  let actual_gitignore = (
    merge-gitignores
      $generic_gitignore
      python
      $environment_gitignore
  )

  let expected_gitignore = ".config
.direnv
.envrc
.pdm-python
.venv

# python
*.pyc
.coverage
__pycache__/
build/
dist/
"

  assert equal $actual_gitignore $expected_gitignore
}

#[test]
def test-merge-justfiles [] {
  let generic_justfile = (get-mock-file $in.mocks justfile-generic.just)
  let environment_justfile = (get-mock-file $in.mocks justfile-environment.just)

  let actual_justfile = (
    merge-justfiles python $generic_justfile $environment_justfile
  )

  let expected_justfile = (get-mock-file $in.mocks justfile-with-environment.just)

  assert equal $actual_justfile (open $expected_justfile | decode utf-8)
}

#[test]
def test-merge-pre-commit-configs [] {
  let generic_pre_commit_config = "repos:
  - repo: https://gitlab.com/vojko.pribudic.foss/pre-commit-update
    rev: v0.5.0
    hooks:
      - id: pre-commit-update
  - repo: https://github.com/gitleaks/gitleaks
    rev: v8.18.4
    hooks:
      - id: gitleaks
  - repo: https://github.com/pre-commit/pre-commit-hooks
    rev: v4.6.0
    hooks:
      - id: check-merge-conflict
      - id: check-yaml
      - id: end-of-file-fixer
      - id: trailing-whitespace
  - repo: https://github.com/DavidAnson/markdownlint-cli2
    rev: v0.14.0
    hooks:
      - id: markdownlint-cli2
        args:
          - --fix
  - repo: https://github.com/pre-commit/mirrors-prettier
    rev: v3.1.0
    hooks:
      - id: prettier
        types:
          - markdown
  - repo: https://github.com/kamadorueda/alejandra
    rev: 3.0.0
    hooks:
      - id: alejandra-system
  - repo: https://github.com/astro/deadnix
    rev: v1.2.1
    hooks:
      - id: deadnix
        args:
          - --edit
  - repo: local
    hooks:
      - id: flake-checker
        name: flake-checker
        entry: flake-checker
        language: system
        pass_filenames: false
      - id: justfile
        name: justfile
        entry: just --fmt --unstable
        language: system
        pass_filenames: false
      - id: statix
        name: statix
        entry: statix fix
        language: system
        pass_filenames: false
      - id: yamlfmt
        name: yamlfmt
        entry: yamlfmt
        language: system
        pass_filenames: false
  - repo: https://github.com/lycheeverse/lychee.git
    rev: v0.15.1
    hooks:
      - id: lychee
        args: [\"--no-progress\", \".\"]
        pass_filenames: false
  - repo: https://github.com/compilerla/conventional-pre-commit
    rev: v3.4.0
    hooks:
      - id: conventional-pre-commit
        stages:
          - commit-msg
"

  let environment_pre_commit_config = "repos:
  - repo: https://github.com/pre-commit/pre-commit-hooks
    rev: v4.6.0
    hooks:
      - id: check-json
      - id: check-toml
      - id: pretty-format-json
        args:
          - --autofix
  - repo: https://github.com/pre-commit/mirrors-prettier
    rev: v3.1.0
    hooks:
      - id: prettier
        types:
          - json
  - repo: local
    hooks:
      - id: taplo
        name: taplo
        entry: taplo format
        language: system
"

  let actual_pre_commit_conifg = (
    merge-pre-commit-configs
      $generic_pre_commit_config
      python
      $environment_pre_commit_config
  )

  let expected_pre_commit_config = "repos:
  - repo: https://gitlab.com/vojko.pribudic.foss/pre-commit-update
    rev: v0.5.0
    hooks:
      - id: pre-commit-update
  - repo: https://github.com/gitleaks/gitleaks
    rev: v8.18.4
    hooks:
      - id: gitleaks
  - repo: https://github.com/pre-commit/pre-commit-hooks
    rev: v4.6.0
    hooks:
      - id: check-merge-conflict
      - id: check-yaml
      - id: end-of-file-fixer
      - id: trailing-whitespace
  - repo: https://github.com/DavidAnson/markdownlint-cli2
    rev: v0.14.0
    hooks:
      - id: markdownlint-cli2
        args:
          - --fix
  - repo: https://github.com/pre-commit/mirrors-prettier
    rev: v3.1.0
    hooks:
      - id: prettier
        types:
          - markdown
  - repo: https://github.com/kamadorueda/alejandra
    rev: 3.0.0
    hooks:
      - id: alejandra-system
  - repo: https://github.com/astro/deadnix
    rev: v1.2.1
    hooks:
      - id: deadnix
        args:
          - --edit
  - repo: local
    hooks:
      - id: flake-checker
        name: flake-checker
        entry: flake-checker
        language: system
        pass_filenames: false
      - id: justfile
        name: justfile
        entry: just --fmt --unstable
        language: system
        pass_filenames: false
      - id: statix
        name: statix
        entry: statix fix
        language: system
        pass_filenames: false
      - id: yamlfmt
        name: yamlfmt
        entry: yamlfmt
        language: system
        pass_filenames: false
  - repo: https://github.com/lycheeverse/lychee.git
    rev: v0.15.1
    hooks:
      - id: lychee
        args: [\"--no-progress\", \".\"]
        pass_filenames: false
  - repo: https://github.com/compilerla/conventional-pre-commit
    rev: v3.4.0
    hooks:
      - id: conventional-pre-commit
        stages:
          - commit-msg
  # python
  - repo: https://github.com/pre-commit/pre-commit-hooks
    rev: v4.6.0
    hooks:
      - id: check-json
      - id: check-toml
      - id: pretty-format-json
        args:
          - --autofix
  - repo: https://github.com/pre-commit/mirrors-prettier
    rev: v3.1.0
    hooks:
      - id: prettier
        types:
          - json
  - repo: local
    hooks:
      - id: taplo
        name: taplo
        entry: taplo format
        language: system
"

  assert equal $actual_pre_commit_conifg $expected_pre_commit_config
}

#[test]
def test-remove-environment-from-gitignore [] {
  let source_gitignore = (get-mock-file $in.mocks .gitignore-with-environment)

  let actual_gitignore = (
    remove-environment-from-gitignore python (open $source_gitignore)
  )

  let expected_gitignore = (get-mock-file $in.mocks .gitignore-generic)

  assert equal $actual_gitignore (open $expected_gitignore)
}

#[test]
def test-remove-environment-from-justfile [] {
  let source_justfile = (get-mock-file $in.mocks justfile-with-environment.just)

  let actual_justfile = (
    remove-environment-from-justfile python (open $source_justfile)
  )

  let expected_justfile = (get-mock-file $in.mocks justfile-generic.just)

  assert equal $actual_justfile (open $expected_justfile)
}

#[test]
def test-remove-environment-from-pre-commit-config [] {
  let source_pre_commit_config = (
    get-mock-file $in.mocks .pre-commit-config-with-environment.yaml
  )

  let actual_pre_commit_config = (
    remove-environment-from-pre-commit-config
      python
      (open --raw $source_pre_commit_config)
  )

  let expected_pre_commit_config = (
    get-mock-file $in.mocks .pre-commit-config-generic.yaml
    )

  assert equal $actual_pre_commit_config (open --raw $expected_pre_commit_config)
}
