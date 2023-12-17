{ config, pkgs, lib, ... }: {
  services.kiwix-serve = {
    enable = true;
    port = 8190;
    zimDir = "/srv/wiki";
  };

  systemd.tmpfiles.rules = [
    "d /srv/wiki 0755 root root -"
  ];
}