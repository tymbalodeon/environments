{pkgs, ...}: {
  packages = with pkgs; [
    cocogitto
    delta
    gh
    git
    # TODO: add a script to run gitleaks checks
    # see https://github.com/gitleaks/gitleaks
    gitleaks
    glab
    jujutsu
    nb
    serie
    tokei
  ];
}
