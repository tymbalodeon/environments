{pkgs, ...}: {
  packages = with pkgs; [
    yaml-language-server
    yamlfmt
    yamllint
  ];
}
