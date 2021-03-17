{ config, lib, pkgs, ... }: {
  home-manager.users.alukard.xdg.configFile."PulseEffects/output/ATH-M50_Harman.json".text =
    (builtins.readFile ./ATH-M50_Harman.json);
  home-manager.users.alukard.xdg.configFile."PulseEffects/output/HE4XX_Harman.json".text =
    (builtins.readFile ./HE4XX_Harman.json);
  home-manager.users.alukard.xdg.configFile."PulseEffects/output/HE4XX.json".text =
    (builtins.readFile ./HE4XX.json);

  systemd.user.services."pulseeffects" = {
    after = [ "sound.target" "pipewire-pulse.service" ];
    description = "PulseEffects daemon";
    wantedBy = [ "default.target" ];
    path = [ pkgs.pulseeffects-pw ];
    serviceConfig.ExecStart = "${pkgs.pulseeffects-pw}/bin/pulseeffects --gapplication-service";
    serviceConfig.ExecStop = "${pkgs.pulseeffects-pw}/bin/pulseeffects --quit";
    serviceConfig.Restart = "on-failure";
  };
}