{ inputs, config, lib, pkgs, ... }: {
  imports = [ inputs.aagl.nixosModules.default ];

  nix.settings = inputs.aagl.nixConfig;
  programs.anime-borb-launcher.enable = true;
  programs.anime-game-launcher.enable = true;
  programs.honkers-railway-launcher.enable = true;
  networking.mihoyo-telemetry.block = lib.mkForce true;

  persist.state.homeDirectories = [
    ".local/share/anime-borb-launcher"
    ".local/share/anime-game-launcher"
    ".local/share/honkers-railway-launcher"
  ];
}
