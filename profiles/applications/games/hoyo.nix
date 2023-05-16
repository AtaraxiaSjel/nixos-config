{ inputs, config, lib, pkgs, ... }: {
  imports = [ inputs.aagl.nixosModules.default ];

  # programs.honkers-railway-launcher.enable = true;
  networking.mihoyo-telemetry.block = true;

  home-manager.users.${config.mainuser}.home.packages = [
    inputs.aagl.packages.${pkgs.hostPlatform.system}.honkers-railway-launcher
  ];

  persist.state.homeDirectories = [
    ".local/share/honkers-railway-launcher"
  ];
}