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
      # FIXME: this doesn't fix rust helix healthcheck. Figure out why!
      lldb
      rust-analyzer
      zellij
    ]
    ++ (
      if stdenv.isDarwin
      then [pkgs.zlib.dev]
      else
        (
          if stdenv.isLinux
          then
            with pkgs; [
              openssl
              pkg-config
            ]
          else []
        )
    );

  shellHook = "export RUST_BACKTRACE=1";
}
