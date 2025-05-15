{pkgs}: {
  packages = with pkgs; [
    alejandra
    deadnix
    flake-checker
    nil
    statix
  ];
}
