{pkgs, ...}: {
  packages = with pkgs;
    [
      cargo
      cargo-bloat
      cargo-edit
      cargo-outdated
      cargo-release
      cargo-udeps
      cargo-watch
      libiconv
      lldb
      openssl
      pkg-config
      rust-analyzer
      zellij
    ]
    ++ (
      if stdenv.isDarwin
      then [pkgs.zlib.dev]
      else []
    );

  shellHook = "export RUST_BACKTRACE=1";
}
