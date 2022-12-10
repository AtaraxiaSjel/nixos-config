{ config, lib, pkgs, ... }: {
  home-manager.users.${config.mainuser} = {
    xdg.configFile = {
      "easyeffects/output/HE4XX.json".text =
        (builtins.readFile ./HE4XX.json);
      "easyeffects/output/Bluetooth.json".text =
        (builtins.readFile ./Bluetooth.json);
    };
    services.easyeffects.enable = true;
  };
}