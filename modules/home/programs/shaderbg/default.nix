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
    home.packages = [ pkgs.shaderbg ];

    systemd.user.services.shaderbg = {
      Unit = {
        Description = "Render shaders as a wallpaper";
        Documentation = "https://github.com/Mr-Pine/shaderbg";
        PartOf = [ cfg.systemd.target ];
        After = [ cfg.systemd.target ];
      };
      Install = {
        WantedBy = [ cfg.systemd.target ];
      };
      Service = {
        ExecStart = pkgs.writeShellScript "shaderbg" ''
          ${lib.getExe pkgs.shaderbg} --fps ${toString cfg.fps} '${cfg.output}' ${cfg.shader}
        '';
      };
    };
  };
}
