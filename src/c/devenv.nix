{
  inputs,
  lib,
  pkgs,
  ...
}: {
  files = import "${inputs.environments}/files.nix" {
    inherit lib;

    environment = "c";
    files = ./files;
  };

  languages.c.enable = true;

  packages = with pkgs; [
    clang-tools
    lldb
    watchexec
    zellij
  ];
}
