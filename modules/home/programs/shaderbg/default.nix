{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib) mkEnableOption mkIf mkOption;
  inherit (lib.types)
    either
    int
    path
    str
    ;
  cfg = config.ataraxia.programs.shaderbg;
in
{
  options.ataraxia.programs.shaderbg = {
    enable = mkEnableOption "Enable shaderbg program";
    shader = mkOption {
      type = either path str;
      description = "Path to shader";
    };
    output = mkOption {
      type = str;
      default = "*";
      description = "Display output. Can be '*' for all outputs";
    };
    fps = mkOption {
      type = int;
      default = 60;
    };
  };

  config = mkIf cfg.enable {
    home.packages = [ pkgs.shaderbg ];

    systemd.user.services.shaderbg = {
      Unit = {
        Description = "Render shaders as a wallpaper";
      };
      Install = {
        WantedBy = [ "default.target" ];
      };
      Service = {
        ExecStart = pkgs.writeShellScript "shaderbg" ''
          ${lib.getExe pkgs.shaderbg} --fps ${toString cfg.fps} '${cfg.output}' ${cfg.shader}
        '';
      };
    };
  };
}
