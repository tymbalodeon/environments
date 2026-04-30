# TODO: handle layout.kdl and score-templates
{
  inputs,
  lib,
  pkgs,
  ...
}: {
  env.FONTCONFIG_FILE = with pkgs;
    makeFontsConf {fontDirectories = [freefont_ttf];};

  files = import "${inputs.environments}/files.nix" {
    inherit lib;

    environment = "lilypond";
    files = ./files;
  };

  outputs.lilypond = "HI";

  packages = with pkgs; [
    gyre-fonts
    lilypond-unstable-with-fonts
    nushell
    tera-cli
    watchexec
    zathura
    zellij
  ];
}
