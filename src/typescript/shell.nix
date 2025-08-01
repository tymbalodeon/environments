{pkgs, ...}: {
  packages = with pkgs; [
    biome
    bun
    nodejs_24
    typescript-language-server
  ];
}
