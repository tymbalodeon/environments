{pkgs, ...}: {
  packages = with pkgs; [
    just
    just-lsp
  ];
}
