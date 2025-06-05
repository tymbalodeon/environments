{pkgs}: {
  packages = with pkgs; [
    nodePackages.pnpm
    python313
    python313Packages.jedi-language-server
    python313Packages.pipx
    python313Packages.python-lsp-server
    python313Packages.vulture
    ruff
    uv
  ];

  shellHook = ''
    uv sync >/dev/null 2>&1 && source .venv/bin/activate
  '';
}
