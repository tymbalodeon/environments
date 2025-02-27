use std assert

use ../dependencies.nu merge-flake-dependencies

let generic_flake = (
  open ([$env.FILE_PWD ./mocks/flake-generic.nix] | path join)
)

let environment_flake = (
  open ([$env.FILE_PWD ./mocks/flake-environment.nix] | path join)
)

let expected_dependencies = "alejandra
ansible-language-server
bat
cocogitto
deadnix
eza
flake-checker
fzf
gh
just
lychee
markdown-oxide
marksman
nil
nodePackages.prettier
nushell
pre-commit
python312Packages.pre-commit-hooks
ripgrep
statix
stylelint
taplo
tokei
vscode-langservers-extracted
yaml-language-server
yamlfmt
"

#[test]
def test-merge-flake-dependencies-generic [] {
  let actual = (merge-flake-dependencies $generic_flake)

  let expected = "alejandra
ansible-language-server
bat
cocogitto
deadnix
eza
flake-checker
fzf
gh
just
lychee
markdown-oxide
marksman
nil
nodePackages.prettier
nushell
pdm
pre-commit
python312Packages.pre-commit-hooks
ripgrep
statix
stylelint
taplo
tokei
vscode-langservers-extracted
yaml-language-server
yamlfmt
"

  assert equal $actual $expected
}

#[test]
def test-merge-flake-dependencies-environment [] {
  let actual = (merge-flake-dependencies $generic_flake $environment_flake)

  let expected = "alejandra
ansible-language-server
bat
cocogitto
deadnix
eza
flake-checker
fzf
gh
git-cliff
just
lychee
markdown-oxide
marksman
nil
nodePackages.pnpm
nodePackages.prettier
nushell
pdm
pre-commit
python311
python311Packages.pre-commit-hooks
python312Packages.pre-commit-hooks
ripgrep
statix
stylelint
taplo
tokei
vscode-langservers-extracted
yaml-language-server
yamlfmt
"

  assert equal $actual $expected
}
