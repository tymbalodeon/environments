{pkgs, ...}: {
  packages = with pkgs; [
    ansible-language-server
    yaml-language-server
    # TODO: add a script to run this
    yamlfmt
  ];
}
