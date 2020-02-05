{ config, lib, pkgs, ... }:
let
  device = config.devices.${config.device};
in {

  # services.acpid.enable = true;
  # users.users.mopidy = {
  #   isNormalUser = false;
  #   extraGroups = [
  #     "smbgrp"
  #   ];
  # };
  # services.mopidy = {
  #   enable = true;
  #   extensionPackages = with pkgs; [ mopidy-local-sqlite ];
  #   configuration = ''
  #     [local]
  #     enabled = true
  #     library = sqlite
  #     media_dir = /media/files/Music
  #     scan_timeout = 1000
  #     scan_flush_threshold = 100
  #     scan_follow_symlinks = false

  #     [local-sqlite]
  #     enabled = true

  #     [audio]
  #     output = pulsesink server=127.0.0.1

  #     [mpd]
  #     hostname = 0.0.0.0
  #   '';
  # };
  # home-manager.users.alukard.home.file.".ncmpcpp/config".text = ''
  #   mpd_host = 127.0.0.1
  #   mpd_port = 6600
  #   mpd_music_dir = "/media/files/Music"
  # '';

  # services.mopidy = {
  #   enable = true;

  #   extensionPackages = with pkgs; [ mopidy-gmusic ];
  #   configuration = (if (!isNull config.secrets.gpmusic) then ''
  #     [gmusic]
  #     username = ${config.secrets.gpmusic.user}
  #     password = ${config.secrets.gpmusic.password}
  #     deviceid = ${config.secrets.gpmusic.deviceid}
  #     bitrate = 128
  #   '' else
  #     "") + ''
  #       [mpd]
  #       hostname = 0.0.0.0
  #     '';
  # };
  services.redshift = {
    enable = true;
    temperature.day = 5500;
    temperature.night = 3000;
  };

  services.earlyoom = {
    enable = device.ram < 12;
    freeMemThreshold = 5;
    freeSwapThreshold = 100;
  };

  services.printing = {
    enable = true;
    drivers = [ pkgs.gutenprint ];
  };
  programs.dconf.enable = true;
  programs.gnupg.agent.enable = true;

  services.accounts-daemon.enable = true;

  services.avahi = {
    enable = true;
    # ipv6 = true;
    nssmdns = true;
    publish = {
      enable = true;
      addresses = true;
      domain = true;
    };
  };

  systemd.services.systemd-udev-settle.enable = false;

  services.upower.enable = true;

  services.gnome3.gnome-keyring.enable = true;

  virtualisation.docker.enable = device.enableDocker;

  # virtualisation.virtualbox.host = lib.mkIf config.deviceSpecific.isHost {
  #   enable = true;
  #   # enableHardening = false;
  #   enableExtensionPack = true;
  # };

  # Install cdemu for some gaming purposes
  # programs.cdemu = {
  #   enable = true;
  #   image-analyzer = false;
  #   gui = false;
  #   group = "cdrom";
  # };

}
