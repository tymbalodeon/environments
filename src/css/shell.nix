{pkgs, ...}: {
  packages = with pkgs; [
    prettierd
    vscode-langservers-extracted
  ];
}
