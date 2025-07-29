{pkgs, ...}: {
  packages = with pkgs; [
    gyre-fonts
    lilypond-unstable-with-fonts
    nushell
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
