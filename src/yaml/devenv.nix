{
  inputs,
  lib,
  pkgs,
  ...
}: {
  files = import "${inputs.environments}/files.nix" {
    inherit lib;

    environment = "yaml";
    files = ./files;
  };

  packages = with pkgs; [
    yaml-language-server
    yamlfmt
    yamllint
  ];
}
