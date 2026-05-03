{
  inputs,
  lib,
  pkgs,
  ...
}: {
  files =
    import "${inputs.environments}/files.nix" {
      inherit lib;

      environment = "git";
      files = ./files;
    }
    # TODO: is it possible to automate overriding feature-level Justfiles as
    # well?
    // {
      ".environments/git/Justfile".text =
        lib.mkForce
        (builtins.readFile
          ../files/Justfile
          + "\n"
          + builtins.readFile ./Justfile);
    };

  tasks."environments:git--release" = {
    before = ["devenv:enterShell"];

    exec =
      # nushell
      ''
        use ${../../default/files/scripts/domain.nu} parse-git-origin
      ''
      + builtins.readFile ./task.nu;

    package = pkgs.nushell;
  };
}
