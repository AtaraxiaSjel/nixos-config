{ config, lib, pkgs, ... }:
with lib;
let
  cfg = config.services.seadrive;
  settingsFormat = pkgs.formats.ini { };
  seadriveConf = if (cfg.settingsFile != null) then
    cfg.settingsFile
  else
    settingsFormat.generate "seadrive.conf" cfg.settings;
in {
  ###### Interface
  options.services.seadrive = {
    enable = mkEnableOption "Seadrive";

    settings = mkOption {
      type = types.submodule {
        freeformType = settingsFormat.type;
      };
      default = {
        account = {
          server = "";
          username = "";
          token = "";
          is_pro = false;
        };
        general = {
          client_name = "nixos";
        };
        cache = {
          size_limit = "10GB";
          clean_cache_interval = 10;
        };
      };
      description = ''
        Configuration for Seadrive.
      '';
    };

    settingsFile = mkOption {
      default = null;
      type = types.nullOr types.path;
    };

    package = mkOption {
      type = types.package;
      description = "Which package to use for the seadrive.";
      default = pkgs.seadrive-fuse;
      defaultText = literalExpression "pkgs.seadrive-fuse";
    };

    mountPoint = mkOption {
      type = types.str;
      default = "/media/seadrive";
    };
  };

  ###### Implementation

  config.home-manager.users.alukard = mkIf cfg.enable {
    systemd.user.services.seadrive-daemon = {
      Service = {
        Type = "simple";
        # Restart = "always";
        ExecStart = ''
          ${cfg.package}/bin/seadrive -c ${seadriveConf} -f -d %h/.seadrive/data ${cfg.mountPoint}
        '';
      };
      Unit = rec {
        After = [ "network.target" ];
        Wants = After;
      };
      Install.WantedBy = [ "multi-user.target" ];
    };
  };
}