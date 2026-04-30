{
  inputs,
  lib,
  pkgs,
  ...
}: {
  files = import "${inputs.environments}/files.nix" {
    inherit lib;

    environment = "java";
    files = ./files;
  };

  languages.java.enable = true;

  packages = with pkgs; [
    google-java-format
    watchexec
    zellij
  ];
}
