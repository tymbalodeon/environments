{pkgs, ...}: {
  packages = with pkgs; [
    # TODO: make its own environment?
    bash
    bat
    eza
    fd
    fzf
    lychee
    nushell
    ripgrep
    # TODO: this is for css; move elsewhere
    stylelint
    # TODO: what are these used for?
    vscode-langservers-extracted
  ];
}
