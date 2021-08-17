{ config, lib, pkgs, ... }: {
  home-manager.users.alukard.xdg.configFile."easyeffects/output/HE4XX.json".text =
    (builtins.readFile ./HE4XX.json);
  home-manager.users.alukard.xdg.configFile."easyeffects/output/Bluetooth.json".text =
    (builtins.readFile ./Bluetooth.json);

  # let
  #   confs = builtins.attrNames (builtins.readDir ./autoload);
  # in
  # home-manager.users.alukard.xdg.configFile."easyeffects/autoload/output/alsa_output.pci-0000_00_1f.3.analog-stereo:output:analog-stereo+input:analog-stereo.json".text =
  # (builtins.readFile ./autoload/alsa_output.pci-0000_00_1f.3.analog-stereo:output:analog-stereo+input:analog-stereo.json);
  # home-manager.users.alukard.xdg.configFile."easyeffects/autoload/output/HE4XX.json".text =
  # (builtins.readFile ./HE4XX.json);

  systemd.user.services."easyeffects" = {
    after = [ "sound.target" "pipewire.service" ];
    description = "EasyEffects daemon";
    wantedBy = [ "multi-user.target" ];
    path = [ pkgs.easyeffects ];
    serviceConfig.ExecStart = "${pkgs.easyeffects}/bin/easyeffects --gapplication-service";
    serviceConfig.ExecStop = "${pkgs.easyeffects}/bin/easyeffects --quit";
    serviceConfig.Restart = "on-failure";
  };
}