{ inputs, lib, ... }: {
  imports = [ inputs.aagl.nixosModules.default ];

  nix.settings = inputs.aagl.nixConfig;
  programs.honkers-railway-launcher.enable = true;
  networking.mihoyo-telemetry.block = lib.mkForce true;

  persist.state.homeDirectories = [
    ".local/share/honkers-railway-launcher"
  ];
}
