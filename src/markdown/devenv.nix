{pkgs, ...}: {
  packages = with pkgs; [
    markdown-oxide
    markdownlint-cli2
    marksman
    prettierd
  ];
}
