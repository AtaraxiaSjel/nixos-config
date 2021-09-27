{ config, lib, pkgs, ... }: {
  home-manager.users.alukard.xdg.configFile."easyeffects/output/HE4XX.json".text =
    (builtins.readFile ./HE4XX.json);
  home-manager.users.alukard.xdg.configFile."easyeffects/output/Bluetooth.json".text =
    (builtins.readFile ./Bluetooth.json);

  home-manager.users.alukard.services.easyeffects.enable = true;

  # home-manager.users.alukard.home.packages = [ pkgs.easyeffects ];

  # systemd.user.services."easyeffects" = {
  #   after = [ "sound.target" "pipewire.service" ];
  #   description = "EasyEffects daemon";
  #   wantedBy = [ "multi-user.target" ];
  #   path = [ pkgs.easyeffects ];
  #   serviceConfig = {
  #     Type = "oneshot";
  #     ExecStart = "${pkgs.easyeffects}/bin/easyeffects --gapplication-service";
  #     ExecStop = "${pkgs.easyeffects}/bin/easyeffects --quit";
  #     Restart = "on-failure";
  #   };
  # };
}