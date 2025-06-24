{pkgs}: {
  packages = with pkgs; [
    alejandra
    deadnix
    flake-checker
    # FIXME: broken
    # Needs to be pinned to an older version (at least on x86_64-darwin)
    # nil
    # nixd
    statix
  ];
}
