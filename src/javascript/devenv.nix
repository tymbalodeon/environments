{
  inputs,
  lib,
  pkgs,
  ...
}: {
  files = import "${inputs.environments}/files.nix" {
    inherit lib;

    environment = "javascript";
    files = ./files;
  };

  languages.javascript = {
    bun = {
      enable = true;
      install.enable = true;
    };

    enable = true;
  };

  packages = with pkgs; [
    biome
  ];
}
