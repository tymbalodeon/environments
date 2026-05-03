{pkgs}: {
  packages = with pkgs; [
    atlas
    colima
    docker
    pgformatter
    postgres-language-server
    postgresql
  ];
}
