use std assert

use ../dependencies.nu merge-flake-dependencies

let generic_flake = (
  open ([$env.FILE_PWD ./mocks/generic-flake.nix] | path join)
)

let environment_flake = (
  open ([$env.FILE_PWD ./mocks/environment-flake.nix] | path join)
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
yamlfmt"

let test_dependencies = [
  {
    actual: (merge-flake-dependencies $generic_flake)
    expected: "alejandra
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
yamlfmt"
  }

  {
    actual: (merge-flake-dependencies $generic_flake $environment_flake)
    expected: "alejandra
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
yamlfmt"
  }
]

for dependencies in $test_dependencies {
  assert equal $dependencies.actual $dependencies.expected
}
