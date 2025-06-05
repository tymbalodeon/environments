{pkgs}: {
  packages = with pkgs; [
    bash
    bat
    eza
    fd
    fzf
    just
    lychee
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
