{
  inputs,
  lib,
  pkgs,
  ...
}: {
  files = import "${inputs.environments}/files.nix" {
    inherit lib;

    environment = "nix";
    files = ./files;
  };

  languages.nix.enable = true;

  packages = with pkgs; [
    alejandra
    deadnix
    flake-checker
    nil
    nixd
    statix
  ];
}
