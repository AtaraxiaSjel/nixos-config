{ config, pkgs, lib, ... }: {
  home-manager.users.alukard = {
    services.syncthing.enable = true;
  };
}