{
  inputs,
  lib,
  pkgs,
  ...
}: {
  files = import "${inputs.environments}/files.nix" {
    inherit lib;

    environment = "git";
    files = ./files;
  };

  tasks."environments:git--release" = {
    before = ["devenv:enterShell"];

    exec =
      # nushell
      ''
        use ${../default/files/scripts/domain.nu} parse-git-origin
      ''
      + builtins.readFile ./task.nu;

    package = pkgs.nushell;
  };
}
