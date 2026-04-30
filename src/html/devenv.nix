{
  inputs,
  lib,
  pkgs,
  ...
}: {
  files = import "${inputs.environments}/files.nix" {
    inherit lib;

    environment = "html";
    files = ./files;
  };

  packages = with pkgs; [
    prettierd
    superhtml
    vscode-langservers-extracted
  ];
}
