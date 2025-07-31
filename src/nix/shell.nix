{pkgs, ...}: {
  packages = with pkgs; [
    # TODO: add a script that will run:
    # nix run github:DeterminateSystems/flake-checker
    # see https://github.com/DeterminateSystems/flake-checker
    alejandra
    # TODO: add a script that will run this
    # what's a good name for this? "prune"?
    deadnix
    flake-checker
    nil
    nixd
    statix
  ];
}
