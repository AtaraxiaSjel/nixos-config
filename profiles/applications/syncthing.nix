{ config, pkgs, lib, ... }: {
  home-manager.users.${config.mainuser} = {
    services.syncthing.enable = true;
  };
}