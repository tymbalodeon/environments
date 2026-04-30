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

  packages = with pkgs; [
    cocogitto
    delta
    gh
    git
    gitleaks
    glab
    jujutsu
    nb
    serie
    tokei
  ];
}
