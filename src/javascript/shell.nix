{pkgs, ...}: {
  packages = with pkgs; [
    biome
    nodejs_24
    typescript-language-server
  ];
}
