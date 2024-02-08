{ config, pkgs, ... }: {
  home-manager.users.${config.mainuser} = {
    home.packages = [ pkgs.cassowary-py ];
  };
  persist.state.homeDirectories = [
    ".config/casualrdh"
  ];
}