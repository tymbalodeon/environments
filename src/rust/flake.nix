{pkgs}: {
  packages = with pkgs;
    [
      cargo
      cargo-bloat
      cargo-edit
      cargo-outdated
      cargo-udeps
      cargo-watch
      libiconv
      rust-analyzer
      zellij
    ]
    ++ (
      if stdenv.isDarwin
      then
        with pkgs; [
          zlib.dev
          (with darwin.apple_sdk.frameworks; [
            CoreFoundation
            CoreServices
            SystemConfiguration
          ])
          darwin.IOKit
        ]
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
