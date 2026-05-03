{
  inputs,
  lib,
  pkgs,
  ...
}: {
  files = import "${inputs.environments}/files.nix" {
    inherit lib;

    environment = "default";
    files = ./files;
  };

  packages = with pkgs; [
    # TODO: make its own environment?
    bash
    bat
    eza
    fd
    fzf
    lychee
    nushell
    ripgrep
    # TODO: this is for css; move elsewhere
    stylelint
    taplo
    # TODO: what are these used for?
    vscode-langservers-extracted
  ];
}
