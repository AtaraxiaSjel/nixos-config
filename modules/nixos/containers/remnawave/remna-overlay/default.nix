{
  config,
  lib,
  pkgs,
  secretsDir,
  ...
}:
let
  inherit (lib) mkEnableOption mkIf;
  inherit (config.ataraxia.lists) ports users;

  cfg = config.ataraxia.containers.remnawave;
in
{
  options.ataraxia.containers.remnawave = {
    remna-overlay = mkEnableOption "Enable remna-overlay extended subscription endpoint";
  };

  config = mkIf cfg.remna-overlay {
    sops.secrets.remna-overlay-env = {
      sopsFile = secretsDir + /${cfg.sopsDir}/remnawave.yaml;
      owner = users.remna-overlay.name;
      restartUnits = [ "remna-overlay.service" ];
    };
    systemd.services.remna-overlay = {
      description = "sing-box XHTTP composer + squad overlay";
      after = [ "network-online.target" ];
      wants = [ "network-online.target" ];
      wantedBy = [ "multi-user.target" ];
      environment = {
        LISTEN_ADDR = "127.0.0.1";
        PORT = ports.remna-overlay.str;
        PANEL_BASE = "http://127.0.0.1:${ports.remna-app.str}";
        OVERLAY_FILE = ./overlay-home.json;
        URLTEST_EXCLUDE_PANEL_TAGS = "NO_URLTEST";
        SELECTOR_EXCLUDE_PANEL_TAGS = "NO_SELECTOR";
      };
      serviceConfig = {
        ExecStart = lib.getExe pkgs.remna-overlay;
        EnvironmentFile = config.sops.secrets.remna-overlay-env.path;
        User = users.remna-overlay.name;
        Restart = "always";
        RestartSec = "5s";
        UMask = "0077";

        NoNewPrivileges = true;
        CapabilityBoundingSet = "";
        PrivateTmp = true;
        PrivateDevices = true;
        PrivateMounts = true;
        PrivateIPC = true;
        ProtectSystem = "strict";
        ProtectHome = true;
        ProtectClock = true;
        ProtectHostname = true;
        ProtectKernelLogs = true;
        ProtectKernelModules = true;
        ProtectKernelTunables = true;
        ProtectControlGroups = true;
        ProtectProc = "invisible";
        ProcSubset = "pid";
        LockPersonality = true;
        RestrictRealtime = true;
        RestrictSUIDSGID = true;
        RestrictNamespaces = true;
        RestrictAddressFamilies = [
          "AF_UNIX"
          "AF_INET"
          "AF_INET6"
          "AF_NETLINK"
        ];
        SystemCallArchitectures = "native";
        SystemCallFilter = "@system-service";
      };
    };
    services.nginx.appendHttpConfig = ''
      map "$http_x_remna_overlay:$http_user_agent" $sub_backend {
        default         http://127.0.0.1:${ports.remna-sub.str};
        "~^1:"          http://127.0.0.1:${ports.remna-sub.str};
        "~^:.*extended" http://127.0.0.1:${ports.remna-overlay.str};
      }
    '';
    users.users.${users.remna-overlay.name} = {
      isSystemUser = true;
      group = users.remna-overlay.name;
      uid = users.remna-overlay.uid;
    };
    users.groups.${users.remna-overlay.name}.gid = users.remna-overlay.gid;
  };
}
