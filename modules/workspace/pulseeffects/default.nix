{ config, lib, pkgs, ... }: {
  # home-manager.users.alukard.xdg.configFile."PulseEffects/output/ATH-M50.json".source = ./ATH-M50.json;
  home-manager.users.alukard.xdg.configFile."PulseEffects/output/ATH-M50.json".text =
    (builtins.readFile ./ATH-M50.json);
  home-manager.users.alukard.xdg.configFile."PulseEffects/output/HE4XX.json".text =
    (builtins.readFile ./HE4XX.json);

  systemd.user.services."pulseeffects" = {
    after = [ "sound.target" ];
    description = "PulseEffects daemon";
    wantedBy = [ "default.target" ];
    path = [ pkgs.pulseeffects ];
    serviceConfig.ExecStart = "${pkgs.pulseeffects}/bin/pulseeffects --gapplication-service";
    serviceConfig.Restart = "on-failure";
  };
}