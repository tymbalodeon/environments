# TODO: how to handle this with javascript?
{
  inputs,
  lib,
  pkgs,
  ...
}: {
  files = import "${inputs.environments}/files.nix" {
    inherit lib;

    environment = "typescript";
    files = ./files;
  };

  languages.typescript.enable = true;

  packages = with pkgs; [
    biome
  ];
}
