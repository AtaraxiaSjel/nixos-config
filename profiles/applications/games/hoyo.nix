{ inputs, lib, ... }: {
  imports = [ inputs.aagl.nixosModules.default ];

  nix.settings = inputs.aagl.nixConfig;
  programs.honkers-railway-launcher.enable = true;
  networking.mihoyo-telemetry.block = lib.mkForce true;

  networking.extraHosts = ''
    0.0.0.0 globaldp-prod-os01.zenlesszonezero.com
    0.0.0.0 apm-log-upload.mihoyo.com
  '';

  persist.state.homeDirectories = [
    ".local/share/honkers-railway-launcher"
  ];
}
