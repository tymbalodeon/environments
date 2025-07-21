{pkgs}: {
  packages = with pkgs; [
    gyre-fonts
    lilypond-unstable-with-fonts
    nushell
    pre-commit
    python312Packages.pre-commit-hooks
    watchexec
    zathura
    zellij
  ];

  shellHook = ''
    export FONTCONFIG_FILE=${
      with pkgs; makeFontsConf {fontDirectories = [freefont_ttf];}
    }
  '';
}
