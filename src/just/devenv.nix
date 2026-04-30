{
  inputs,
  lib,
  pkgs,
  ...
}: {
  files = import "${inputs.environments}/files.nix" {
    inherit lib;

    environment = "just";
    files = ./files;
  };

  packages = with pkgs; [
    just
    just-lsp
  ];
}
