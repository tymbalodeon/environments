{pkgs, ...}: {
  packages = with pkgs; [
    typst
    tinymist
    typstyle
  ];
}
