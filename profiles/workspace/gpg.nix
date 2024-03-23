{ config, pkgs, lib, ... }:
with config.deviceSpecific; {
  home-manager.users.${config.mainuser} = {
    programs.gpg = {
      enable = true;
      homedir = config.services.password-store.gnupgHome;
    };
    services.gpg-agent = {
      enable = true;
      enableSshSupport = true;
      pinentryPackage = if !isServer then pkgs.pinentry-gnome3 else pkgs.pinentry-curses;
      sshKeys = [
        "7A7130ABF128CC2C32B3D6AD27515056B0193CE1"
        "E6A6377C3D0827C36428A290199FDB3B91414AFE"
      ];
    };
    systemd.user.services.gpg-agent = {
      Service = {
        Environment = lib.mkForce [
          "GPG_TTY=/dev/tty1"
          "DISPLAY=:0"
          "GNUPGHOME=${config.services.password-store.gnupgHome}"
        ];
      };
    };
  };
  services.dbus.packages = lib.mkIf (!isServer) [ pkgs.gcr ];
  persist.state.homeDirectories = [ ".local/share/gnupg" ];
}