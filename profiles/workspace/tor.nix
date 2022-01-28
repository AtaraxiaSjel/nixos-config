{ config, pkgs, lib, ... }: {
  services.tor = {
    enable = true;
    client.enable = true;
  };
  services.privoxy = {
    enable = true;
    enableTor = true;
  };
}