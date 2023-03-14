{ config, lib, pkgs, ... }:
with lib;
let
  cfg = config.services.seadrive;
  format = pkgs.formats.ini { };

  settings = {
    account = {
      server = cfg.settings.server;
      username = cfg.settings.username;
      token = "#token#";
      is_pro = cfg.settings.isPro;
    };
    general = {
      client_name = cfg.settings.clientName;
    };
    cache = {
      size_limit = cfg.settings.sizeLimit;
      clean_cache_interval = cfg.settings.cleanCacheInterval;
    };
  };

  configFile = format.generate "seadrive.conf" settings;

  startScript = pkgs.writeShellScript "start-seadrive" ''
    token=$(head -n1 ${cfg.settings.tokenFile})
    cp -f ${configFile} ${cfg.stateDir}/seadrive.conf
    sed -e "s,#token#,$token,g" -i "${cfg.stateDir}/seadrive.conf"
    chmod 440 "${cfg.stateDir}/seadrive.conf"

    mkdir -p ${cfg.mountPoint} || true

    ${cfg.package}/bin/seadrive -c ${cfg.stateDir}/seadrive.conf -f -d ${cfg.stateDir}/data -l ${cfg.stateDir}/logs ${cfg.mountPoint}
  '';
in {
  options.services.seadrive = {
    enable = mkEnableOption "Seadrive";

    settings = mkOption {
      default = { };
      description = lib.mdDoc ''
      '';

      type = types.submodule {
        freeformType = format.type;

        options = {
          server = mkOption {
            type = types.str;
            default = "";
            description = lib.mdDoc "";
          };
          username = mkOption {
            type = types.str;
            default = "";
            description = lib.mdDoc "";
          };
          tokenFile = mkOption {
            type = types.str;
            default = "";
            description = lib.mdDoc "";
          };
          isPro = mkOption {
            type = types.bool;
            default = false;
            description = lib.mdDoc "";
          };
          clientName = mkOption {
            type = types.str;
            default = config.networking.hostName;
            description = lib.mdDoc "";
          };
          sizeLimit = mkOption {
            type = types.str;
            default = "10GB";
            description = lib.mdDoc "";
          };
          cleanCacheInterval = mkOption {
            type = types.int;
            default = 10;
            description = lib.mdDoc "";
          };
        };
      };
    };

    package = mkOption {
      type = types.package;
      description = lib.mdDoc "Which package to use for the seadrive.";
      default = pkgs.seadrive-fuse;
      defaultText = literalExpression "pkgs.seadrive-fuse";
    };

    mountPoint = mkOption {
      type = types.str;
      default = "/media/seadrive";
      description = lib.mdDoc "";
    };

    stateDir = mkOption {
      type = types.str;
      default = "~/.seadrive";
      description = lib.mdDoc "";
    };
  };

  config = mkIf cfg.enable {
    systemd.user.services.seadrive = rec {
      serviceConfig.ExecStart = startScript;
      after = [ "network-online.target" ];
      wants = after;
      wantedBy = [ "default.target" ];
    };
  };
}