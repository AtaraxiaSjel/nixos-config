{
  config,
  lib,
  pkgs,
  secretsDir,
  ...
}:
let
  inherit (lib)
    mkEnableOption
    mkPackageOption
    mkIf
    mkOption
    ;
  inherit (lib.types) str;
  cfg = config.ataraxia.vpn.sing-box;
  isNetworkd = config.networking.useNetworkd;
in
{
  options.ataraxia.vpn.sing-box = {
    enable = mkEnableOption "Enable sing-box proxy service";
    package = mkPackageOption pkgs "sing-box" { };
    config = mkOption {
      type = str;
      description = "Name of sing-box config in sops secret";
    };
    interfaceName = mkOption {
      type = str;
      default = "singtun0";
      description = "Name of sing-box tunnel network interface";
    };
  };

  config = mkIf cfg.enable {
    sops.secrets.${cfg.config} = {
      sopsFile = secretsDir + /proxy.yaml;
      restartUnits = [ "sing-box.service" ];
      mode = "0600";
    };

    environment.systemPackages = [ cfg.package ];

    systemd.packages = [ cfg.package ];

    systemd.services.sing-box = {
      preStart = ''
        umask 0007
        mkdir -p ''${RUNTIME_DIRECTORY}
        cp ${config.sops.secrets.${cfg.config}.path} ''${RUNTIME_DIRECTORY}/config.json
      '';
      serviceConfig = {
        StateDirectory = "sing-box";
        StateDirectoryMode = "0700";
        RuntimeDirectory = "sing-box";
        RuntimeDirectoryMode = "0700";
        ExecStart = [
          ""
          "${lib.getExe cfg.package} -D \${STATE_DIRECTORY} -C \${RUNTIME_DIRECTORY} run"
        ];
      };
      wantedBy = [ "multi-user.target" ];
    };

    networking.dhcpcd.denyInterfaces = [ cfg.interfaceName ];

    systemd.network = {
      wait-online.ignoredInterfaces = [ cfg.interfaceName ];
      networks."50-singbox" = mkIf isNetworkd {
        matchConfig = {
          Name = cfg.interfaceName;
        };
        linkConfig = {
          Unmanaged = true;
          ActivationPolicy = "manual";
        };
      };
    };
  };
}
