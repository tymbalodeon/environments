{pkgs, ...}: {
  packages = with pkgs; [
    sqlfluff
  ];
}
