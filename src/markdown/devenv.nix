{
  inputs,
  lib,
  pkgs,
  ...
}: {
  files = import "${inputs.environments}/files.nix" {
    inherit lib;

    environment = "markdown";
    files = ./files;
  };

  packages = with pkgs; [
    markdown-oxide
    markdownlint-cli2
    marksman
    prettierd
  ];
}
