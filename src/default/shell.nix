{pkgs, ...}: {
  packages = with pkgs; [
    # TODO: make its own environment?
    bash
    bat
    eza
    fd
    fzf
    # TODO: what is pretier used for here? Should it be removed/moved elsewhere?
    nodePackages.prettier
    nushell
    ripgrep
    # TODO: this is for css; move elsewhere
    stylelint
    # TODO: what are these used for?
    vscode-langservers-extracted
  ];
}
