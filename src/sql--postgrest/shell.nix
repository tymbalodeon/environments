{pkgs}: {
  packages = with pkgs; [
    openssl
    postgrest
  ];
}
