{ config, pkgs, ... }: {
  home-manager.users.${config.mainuser} = {
    home.packages = [ pkgs.nicotine-plus ];
  };

  networking.firewall.allowedTCPPorts = [ 2234 ];

  persist.state.homeDirectories = [
    ".config/nicotine"
    ".local/share/nicotine"
  ];
}