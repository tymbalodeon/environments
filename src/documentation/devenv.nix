{
  inputs,
  lib,
  pkgs,
  ...
}: {
  files = import "${inputs.environments}/files.nix" {
    inherit lib;

    environment = "documentation";
    files = ./files;
  };

  packages = with pkgs; [
    mdbook
    yamlfmt
  ];

  tasks."environments:documentation" = {
    before = ["devenv:enterShell"];
    exec = builtins.readFile ./task.nu;
    package = pkgs.nushell;
  };
}
