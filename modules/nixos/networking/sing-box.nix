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
  inherit (config.ataraxia.lists) users;
  cfg = config.ataraxia.vpn.sing-box;
  isNetworkd = config.networking.useNetworkd;
in
{
  options.ataraxia.vpn.sing-box = {
    enable = mkEnableOption "Enable sing-box proxy service";
    autoStart = mkEnableOption "Start sing-box service on boot";
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
      owner = "sing-box";
    };

    environment.systemPackages = [ cfg.package ];

    systemd.packages = [ cfg.package ];

    users.users.${users.singbox.name} = {
      group = users.singbox.name;
      isSystemUser = true;
      uid = users.singbox.uid;
    };
    users.groups.${users.singbox.name}.gid = users.singbox.gid;

    systemd.services.sing-box = {
      preStart = ''
        umask 0007
        mkdir -p ''${RUNTIME_DIRECTORY}
        cp ${config.sops.secrets.${cfg.config}.path} ''${RUNTIME_DIRECTORY}/config.json
      '';
      serviceConfig = {
        User = users.singbox.name;
        Group = users.singbox.name;
        StateDirectory = "sing-box";
        StateDirectoryMode = "0700";
        RuntimeDirectory = "sing-box";
        RuntimeDirectoryMode = "0700";
        ExecStart = [
          ""
          "${lib.getExe cfg.package} -D \${STATE_DIRECTORY} -C \${RUNTIME_DIRECTORY} run"
        ];
      };
      wantedBy = mkIf cfg.autoStart [ "multi-user.target" ];
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
