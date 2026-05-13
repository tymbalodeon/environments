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
    # TODO: requires adding oxalica
    # channel = "nightly";
    enable = true;
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
}
