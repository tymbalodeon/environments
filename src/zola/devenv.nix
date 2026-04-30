{
  inputs,
  lib,
  pkgs,
  ...
}: {
  files = import "${inputs.environments}/files.nix" {
    inherit lib;

    environment = "zola";
    files = ./files;
  };

  packages = with pkgs; [
    zellij
    zola
  ];
}
