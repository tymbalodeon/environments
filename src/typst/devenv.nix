{pkgs, ...}: {
  env.ENVIRONMENTS_TYPST_ZELLIJ_LAYOUT = ./layout.kdl;
  languages.typst.enable = true;

  packages = with pkgs; [
    tinymist
    typstyle
  ];
}
