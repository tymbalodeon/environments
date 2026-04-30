{
  inputs,
  lib,
  pkgs,
  ...
}: {
  files = import "${inputs.environments}/files.nix" {
    inherit lib;

    environment = "css";
    files = ./files;
  };

  packages = with pkgs; [
    prettierd
    vscode-langservers-extracted
  ];
}
