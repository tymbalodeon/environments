{
  inputs,
  lib,
  pkgs,
  ...
}: {
  files =
    import "${inputs.environments}/files.nix" {
      inherit lib;

      environment = "python";
      files = ./files;
    }
    // {
      ".environments/python/Justfile".text =
        lib.mkForce
        (builtins.readFile
          ../files/Justfile
          + "\n"
          + builtins.readFile ./Justfile);
    };

  tasks."environments:python--build" = {
    before = ["devenv:enterShell"];
    exec = builtins.readFile ./task.nu;
    package = pkgs.nushell;
  };

  packages = [pkgs.taplo];
}
