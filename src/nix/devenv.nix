{pkgs, ...}: {
  languages.nix.enable = true;

  packages = with pkgs; [
    alejandra
    deadnix
    flake-checker
    nil
    nixd
    statix
  ];
}
