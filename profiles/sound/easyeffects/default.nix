{ config, lib, pkgs, ... }: {
  home-manager.users.alukard.xdg.configFile."easyeffects/output/HE4XX.json".text =
    (builtins.readFile ./HE4XX.json);
  home-manager.users.alukard.xdg.configFile."easyeffects/output/Bluetooth.json".text =
    (builtins.readFile ./Bluetooth.json);

  home-manager.users.alukard.services.easyeffects.enable = true;
}