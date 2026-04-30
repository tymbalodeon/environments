{
  inputs,
  lib,
  pkgs,
  ...
}: {
  files = import "${inputs.environments}/files.nix" {
    inherit lib;

    environment = "haskell";
    files = ./files;
  };

  languages.haskell.enable = true;

  packages = with pkgs; [
    fourmolu
  ];
}
