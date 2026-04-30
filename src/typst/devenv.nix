{
  inputs,
  lib,
  pkgs,
  ...
}: {
  files = import "${inputs.environments}/files.nix" {
    inherit lib;

    environment = "typst";
    files = ./files;
  };

  languages.typst.enable = true;

  packages = with pkgs; [
    tinymist
    typstyle
  ];
}
