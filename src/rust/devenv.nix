{
  inputs,
  lib,
  pkgs,
  ...
}: {
  env.RUST_BACKTRACE = 1;

  files = import "${inputs.environments}/files.nix" {
    inherit lib;

    environment = "rust";
    files = ./scripts;
  };

  languages.rust = {
    enable = true;
    toolchainFile = "${inputs.project}/rust-toolchain.toml";
  };

  packages = with pkgs; [
    cargo
    cargo-bloat
    cargo-edit
    cargo-outdated
    cargo-release
    cargo-udeps
    cargo-watch
    dioxus-cli
    libiconv
    lldb
    openssl
    pkg-config
    rust-analyzer
    zellij
  ];

  tasks."environments:rust" = {
    before = ["devenv:enterShell"];

    exec =
      ''
        def rust-toolchain-file [] {
          "${builtins.readFile ./rust-toolchain.toml}"
        }
      ''
      + builtins.readFile ./task.nu;

    package = pkgs.nushell;
  };
}
