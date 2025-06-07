{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib) mkEnableOption mkIf;
  cfg = config.ataraxia.security.pass-secret-service;
in
{
  options.ataraxia.security.pass-secret-service = {
    enable = mkEnableOption "Whether to enable pass-secret-service";
  };

  config = mkIf cfg.enable {
    home.packages = [ pkgs.pass-secret-service ];
    dbus.packages = [ pkgs.pass-secret-service ];
    xdg.portal.extraPortals = [ pkgs.pass-secret-service ];

    services.pass-secret-service.enable = true;
    systemd.user.services.pass-secret-service = {
      Service.Environment = [
        "GPG_TTY=/dev/tty1"
        "DISPLAY=:0"
      ];
      Unit = rec {
        Wants = [ "gpg-agent.service" ];
        After = Wants;
        PartOf = [ "graphical-session-pre.target" ];
      };
    };
  };
}
