{pkgs, ...}: {
  packages = with pkgs; [
    # TODO: add a script to run just --fmt
    just
  ];
}
