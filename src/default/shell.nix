{pkgs, ...}: {
  packages = with pkgs; [
    bash
    bat
    eza
    fd
    fzf
    # FIXME (doesn't build)
    # TODO: add a script to run this
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
