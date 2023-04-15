{ config, pkgs, lib, ... }: {
  home-manager.users.${config.mainuser} = {
    home.packages = [
      pkgs.cassowary-py
    ];

    # xdg.configFile."casualrdh/config.json".text = toJson ''
    # '';
    # xdg.desktopEntries
  };

  persist.state.homeDirectories = [
    ".config/casualrdh"
  ];
}