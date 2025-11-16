{pkgs}: {
  packages = with pkgs; [
    pgformatter
    postgres-lsp
    postgresql
  ];
}
