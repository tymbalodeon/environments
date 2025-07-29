{pkgs, ...}: {
  packages = with pkgs; [
    # TODO: add a script that will run the linter
    # see https://github.com/DavidAnson/markdownlint-cli2
    markdownlint-cli2
    # TODO: add a script that will run the formatter
    prettierd
  ];
}
