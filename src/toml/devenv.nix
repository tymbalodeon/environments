{
  inputs,
  lib,
  pkgs,
  ...
}: {
  files = import "${inputs.environments}/files.nix" {
    inherit lib;

    environment = "toml";
    files = ./files;
  };

  packages = with pkgs; [
    taplo
  ];
}
