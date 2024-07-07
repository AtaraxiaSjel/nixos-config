{ config, lib, pkgs, ... }:

with lib;
let
  cfg = config.services.kiwix-serve;
in
{
  options = {
    services.kiwix-serve = {
      enable = mkOption {
        default = false;
        type = types.bool;
      };
      package = mkOption {
        type = types.package;
        default = pkgs.kiwix-tools;
        defaultText = literalExpression "pkgs.kiwix-tools";
        description = "The package that provides `bin/kiwix-serve`";
      };
      port = mkOption {
        type = types.port;
        default = 80;
        description = "Port number to listen on";
      };
      listenAddress = mkOption {
        type = types.str;
        default = "127.0.0.1";
        description = "IP address to listen on";
      };
      zimPaths = mkOption {
        default = null;
        type = types.nullOr (types.nonEmptyListOf (types.either types.str types.path));
        description = "ZIM file path(s)";
      };
      zimDir = mkOption {
        default = null;
        type = types.nullOr (types.either types.str types.path);
        description = "ZIM directory";
      };
    };
  };

  config = mkIf cfg.enable {
    systemd.services.kiwix-serve = {
      description = "Deliver ZIM file(s) articles via HTTP";
      after = [ "network.target" ];
      wantedBy = [ "multi-user.target" ];

      serviceConfig = let
        bindsPrivilegedPort = (0 < cfg.port && cfg.port < 1024);
        maybeZimPaths = lib.optionals (cfg.zimPaths != null) cfg.zimPaths;
        maybeZimDir = lib.optionals (cfg.zimDir != null) ["-l" "/tmp/library.xml"];
        args = ["-i" cfg.listenAddress] ++ ["-p" cfg.port] ++ maybeZimDir ++ maybeZimPaths;

        manage-lib = pkgs.writeShellScript "kiwix-manage-library" ''
          for f in "${cfg.zimDir}"/*.zim; do
            if [[ -f "$f" ]]; then
              ( set -x; ${cfg.package}/bin/kiwix-manage "/tmp/library.xml" add $f )
            fi
          done
        '';
      in {
        ExecStartPre = lib.mkIf (cfg.zimDir != null) manage-lib;
        ExecStart = "${cfg.package}/bin/kiwix-serve ${lib.escapeShellArgs args}";
        Type = "simple";
        Restart = "on-failure";
        TimeoutStartSec = 600;

        AmbientCapabilities   = [""] ++ lib.optional bindsPrivilegedPort "CAP_NET_BIND_SERVICE";
        CapabilityBoundingSet = [""] ++ lib.optional bindsPrivilegedPort "CAP_NET_BIND_SERVICE";
        DevicePolicy = "closed";
        DynamicUser = true;
        LockPersonality = true;
        MemoryDenyWriteExecute = true;
        NoNewPrivileges = true;
        PrivateDevices = true;
        PrivateMounts = true;
        PrivateTmp = true;
        PrivateIPC = true;
        PrivateUsers = true;
        ProcSubset = "pid";
        ProtectClock = true;
        ProtectControlGroups = true;
        ProtectHome = true;
        ProtectHostname = true;
        ProtectKernelLogs = true;
        ProtectKernelModules = true;
        ProtectKernelTunables = true;
        ProtectProc = "invisible";
        ProtectSystem = "strict";
        RemoveIPC = true;
        RestrictAddressFamilies = [ "AF_UNIX" "AF_INET" "AF_INET6" "AF_NETLINK" ];
        RestrictNamespaces = true;
        RestrictRealtime = true;
        RestrictSUIDSGID = true;
        SystemCallArchitectures = "native";
        SystemCallFilter = [ "@system-service" "~@privileged" ];
        SystemCallErrorNumber = "EPERM";
        UMask = "0002";
      };
    };
  };
}
