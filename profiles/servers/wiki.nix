{ config, pkgs, lib, ... }: {
  services.kiwix-serve = {
    enable = true;
    port = 8190;
    zimDir = "/media/nas/media-stack/torrents/other";
  };
}