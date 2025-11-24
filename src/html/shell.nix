{pkgs, ...}: {
  packages = with pkgs; [
    prettierd
    superhtml
    vscode-langservers-extracted
  ];
}
