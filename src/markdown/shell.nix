{pkgs, ...}: {
  packages = with pkgs; [
    markdownlint-cli2
    prettierd
  ];
}
