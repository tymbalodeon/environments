{
  inputs,
  lib,
  pkgs,
  ...
}: {
  # TODO: can this pull in everything from the other module folders without
  # having to add them to the devenv.yaml file? this may require restructring so
  # this is in a higher level folder than the others?
  files = import "${inputs.environments}/files.nix" {
    inherit lib;

    environment = "default";
    files = ./files;
  };

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
