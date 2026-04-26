{
  inputs,
  lib,
  pkgs,
  ...
}:
if (builtins.getEnv "ENVIRONMENT_JAVASCRIPT") != ""
then {
  files = import "${inputs.files}/files.nix" {
    inherit lib;
    environment = "javascript";
    files = ./files;
  };

  outputs.javascript = {
    aliases = ["js"];
    helixConfiguration = builtins.readFile ./languages.toml;
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
    bun
    nodejs_24
    typescript-language-server
  ];
}
else {}
