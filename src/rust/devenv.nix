{
  inputs,
  lib,
  pkgs,
  ...
}: {
  env = {
    ENVIRONMENTS_RUST_ZELLIJ_LAYOUT = ./layout.kdl;
    RUST_BACKTRACE = 1;
  };

  files = import "${inputs.environments}/files.nix" {
    inherit lib;

    environment = "rust";
    files = ./scripts;
  };

  languages.rust = {
    channel = "nightly";
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
