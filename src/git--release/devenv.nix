{
  inputs,
  lib,
  pkgs,
  ...
}: {
  files = import "${inputs.environments}/files.nix" {
    inherit lib;

    environment = "git";
    files = ./files;
  };
}
