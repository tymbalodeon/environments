{
  # config,
  inputs,
  # lib,
  # pkgs,
  ...
}: {
  packages = builtins.trace (builtins.attrNames inputs.python.devenv.config) [];
}
