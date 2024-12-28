{ config, lib, ... }: {
  home-manager.users.${config.mainuser} = {
    services.hyprpaper = {
      enable = true;
      settings = {
        preload = ["${/. + ../../../misc/wallpaper.png}"];
        wallpaper = [", ${/. + ../../../misc/wallpaper.png}"];
      };
    };

    systemd.user.services.hyprpaper.Unit.After = lib.mkForce "graphical-session.target";
  };
}