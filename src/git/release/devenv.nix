{pkgs, ...}: {
  tasks."environments:git--release" = {
    before = ["devenv:enterShell"];

    exec =
      # nushell
      ''
        use ${../../default/scripts/domain.nu} parse-git-origin
      ''
      + builtins.readFile ./task.nu;

    package = pkgs.nushell;
  };
}
