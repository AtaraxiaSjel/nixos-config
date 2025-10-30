{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib) mkEnableOption mkIf mkOption;
  inherit (lib.types) either path str;
  cfg = config.ataraxia.programs.mpvpaper;
in
{
  options.ataraxia.programs.mpvpaper = {
    enable = mkEnableOption "Enable mpvpaper program";
    wallpaper = mkOption {
      description = "Path to wallpaper file";
      type = either str path;
    };
  };

  config = mkIf cfg.enable {
    home.packages = [ pkgs.mpvpaper ];

    systemd.user.services.mpvpaper = {
      Unit = {
        Description = "Video wallpaper for wayland desktops";
      };
      Install = {
        WantedBy = [ "default.target" ];
      };
      Service = {
        ExecStart = pkgs.writeShellScript "mpvpaper" ''
          ${lib.getExe pkgs.mpvpaper} -p -o "no-audio loop" ALL ${cfg.wallpaper}
        '';
        # Restart every hour because of memory leak in mpvpaper
        Restart = "always";
        RuntimeMaxSec = "1h";
      };
    };
  };
}
