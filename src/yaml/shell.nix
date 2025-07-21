{pkgs, ...}: {
  packages = with pkgs; [
    ansible-language-server
    yaml-language-server
    yamlfmt
  ];
}
