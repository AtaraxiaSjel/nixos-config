{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib)
    literalExpression
    mkEnableOption
    mkIf
    mkOption
    ;
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
    systemd = {
      enable = mkEnableOption "Shaderbg systemd integration" // {
        default = true;
      };
      target = mkOption {
        type = str;
        default = config.wayland.systemd.target;
        defaultText = literalExpression "config.wayland.systemd.target";
        example = "sway-session.target";
        description = "The systemd target that will automatically start the shaderbg service.";
      };
    };
  };

  config = mkIf cfg.enable {
    home.packages = [ pkgs.mpvpaper ];

    systemd.user.services.mpvpaper = {
      Unit = {
        Description = "Video wallpaper for wayland desktops";
        Documentation = "https://github.com/GhostNaN/mpvpaper";
        PartOf = [ cfg.systemd.target ];
        After = [ cfg.systemd.target ];
      };
      Install = {
        WantedBy = [ cfg.systemd.target ];
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
