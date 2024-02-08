{ config, pkgs, ... }: {
  home-manager.users.${config.mainuser} = {
    home.packages = [ pkgs.gnome.geary ];
  };

  defaultApplications.mail = {
    cmd = "${pkgs.gnome.geary}/bin/geary";
    desktop = "geary";
  };

  startupApplications = [
    config.defaultApplications.mail.cmd
  ];

  persist.state.homeDirectories = [
    ".config/geary"
    ".local/share/geary"
  ];
}