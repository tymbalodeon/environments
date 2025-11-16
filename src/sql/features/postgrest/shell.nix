{pkgs}: {
  packages = with pkgs; [
    atlas
    colima
    docker
    openssl
    postgrest
  ];
}
