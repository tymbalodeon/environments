{pkgs}: {
  packages = with pkgs; [
    nodePackages.pnpm
    pipx
    python313
    ruff
    uv
  ];
}
