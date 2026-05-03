{
  inputs,
  lib,
  pkgs,
  ...
}: {
  files = import "${inputs.environments}/files.nix" {
    inherit lib;

    environment = "sql";
    files = ./files;
  };

  packages = with pkgs; [
    openssl
    postgrest
  ];
}
