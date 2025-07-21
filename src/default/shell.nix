{pkgs, ...}: {
  packages = with pkgs; [
    bash
    bat
    eza
    fd
    fzf
    just
    # FIXME (doesn't build)
    # lychee
    markdown-oxide
    marksman
    nodePackages.prettier
    nushell
    ripgrep
    stylelint
    tera-cli
    vscode-langservers-extracted
  ];
}
