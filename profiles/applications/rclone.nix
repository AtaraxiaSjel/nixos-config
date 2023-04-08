{ config, pkgs, lib, ... }: {
  home-manager.users.${config.mainuser}.home.packages = [
    pkgs.rclone
  ];
}