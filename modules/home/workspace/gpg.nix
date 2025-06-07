{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib) mkEnableOption mkIf;
  cfg = config.ataraxia.defaults.gpg;
in
{
  options.ataraxia.defaults.gpg = {
    enable = mkEnableOption "Default gpg settings";
  };

  config = mkIf cfg.enable {
    programs.gpg = {
      enable = true;
      homedir = "${config.xdg.dataHome}/gnupg";
    };
    services.gpg-agent = {
      enable = true;
      enableSshSupport = true;
      pinentry.package = pkgs.pinentry-gnome3;
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
          "GNUPGHOME=${config.programs.gpg.homedir}"
        ];
      };
    };

    persist.state.directories = [ ".local/share/gnupg" ];
  };
}
