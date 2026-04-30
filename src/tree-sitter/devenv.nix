{
  inputs,
  lib,
  pkgs,
  ...
}: {
  files = import "${inputs.environments}/files.nix" {
    inherit lib;

    environment = "tree-sitter";
    files = ./files;
  };

  packages = with pkgs; [
    bun
    chuck
    clang
  ];
}
